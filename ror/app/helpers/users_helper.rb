# Stores IO functions for user Class
#
# @author Eric Fehr (eric.fehr@publicis-modem.fr, @github: ricofehr)
module UsersHelper

  # Delete key files
  #
  # No param
  # No return
  def delete_keyfiles
    system("rm -f sshkeys/#{self.email}*")
    system("rm -f vpnkeys/#{self.email}*")
  end

  # Generate own modem ssh key
  #
  # No param
  # No return
  def generate_authorizedkeys
    system('mkdir -p sshkeys')
    system("rm -f sshkeys/#{self.email}.authorized_keys")
    system("touch sshkeys/#{self.email}.authorized_keys")
    # add server mvmc public key to authorized_keys
    system("cat ~/.ssh/id_rsa.pub > sshkeys/#{self.email}.authorized_keys")
    Sshkey.admins.each { |k| system("echo #{k.key} >> sshkeys/#{self.email}.authorized_keys") }
    self.sshkeys.each { |k| system("echo #{k.key} >> sshkeys/#{self.email}.authorized_keys") }
    system("chmod 777 sshkeys/*")
  end

  # Generate again all authorized_keys (trigerred after change with admin ssh keys)
  #
  # No param
  # No return
  def generate_all_authorizedkeys
    User.all.each { |k| k.generate_authorizedkeys }
  end

  # Upload authorized_keys updated to the active vm for the user
  #
  # No param
  # No return
  def upload_authorizedkeys
    self.vms.each { |k|
      Rails.logger.warn "rsync -avzPe \"ssh -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null\" sshkeys/#{self.email}.authorized_keys modem@#{k.floating_ip}:~/.ssh/authorized_keys"
      system("rsync -avzPe \"ssh -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null\" sshkeys/#{self.email}.authorized_keys modem@#{k.floating_ip}:~/.ssh/authorized_keys") 
    }
  end

  # Generate own openvpn key
  #
  # No param
  # No return
  def generate_openvpn_keys
    system("cd vpnkeys/bin && source ./vars && KEY_EMAIL=#{self.email} ./build-key #{self.email}")
  end

  # Get server certificate
  #
  # No param
  # No return
  def openvpn_ca
    File.open("vpnkeys/ca.crt", "rb").read
  end

  # Get own vpn key
  #
  # No param
  # No return
  def openvpn_key
    generate_openvpn_keys unless File.file?("vpnkeys/#{self.email}.key") && File.file?("vpnkeys/#{self.email}.csr")
    File.open("vpnkeys/#{self.email}.key", "rb").read
  end

  # Get own vpn key
  #
  # No param
  # No return
  def openvpn_crt
    generate_openvpn_keys unless File.file?("vpnkeys/#{self.email}.key") && File.file?("vpnkeys/#{self.email}.csr")
    File.open("vpnkeys/#{self.email}.crt", "rb").read
  end

  # Generate openvpn conf
  #
  # No param
  # @raise an exception if errors occurs during file reading
  # No return
  def openvpn_conf
    template = "vpnkeys/conf/mvmc.conf"

    begin
      pattern = IO.read(template)
      pattern.gsub!('%{email}', self.email)
      pattern.gsub!('%{ovpnip}', Rails.application.config.ovpnip)
      pattern.gsub!('%{ovpnport}', Rails.application.config.ovpnport)
    rescue Exception => e
      raise Exceptions::MvmcException.new("Create mvmc.conf file for #{self.email} failed: #{e}")
    end
  end

  # Generate own modem ssh key
  #
  # No param
  # No return
  def generate_sshkey_modem
    system("mkdir -p sshkeys")
    system("rm -f sshkeys/#{self.email}")
    system("rm -f sshkeys/#{self.email}.pub")
    system("ssh-keygen -f sshkeys/#{self.email} -N ''")
    system("chmod 777 sshkeys/*")
    @gitlabapi.add_sshkey(gitlab_user, "modemsshkey", public_sshkey_modem)
  end

  # Copy modem ssh key
  #
  # @param emailsrc (String): user from which we copy modemkeys
  # No return
  def copy_sshkey_modem(emailsrc)
    system("mkdir -p sshkeys")
    system("cp -f sshkeys/#{emailsrc} sshkeys/#{self.email}")
    system("cp -f sshkeys/#{emailsrc}.pub sshkeys/#{self.email}.pub")
    system("chmod 777 sshkeys/*")
  end

  # Get private own modem ssh key
  #
  # No param
  # No return
  def private_sshkey_modem
    generate_sshkey_modem unless File.file?("sshkeys/#{self.email}") && File.file?("sshkeys/#{self.email}.pub")
    File.open("sshkeys/#{self.email}", "rb").read
  end

  # Get public own modem ssh key
  #
  # No param
  # No return
  def public_sshkey_modem
    generate_sshkey_modem unless File.file?("sshkeys/#{self.email}") && File.file?("sshkeys/#{self.email}.pub")
    File.open("sshkeys/#{self.email}.pub", "rb").read
  end
end