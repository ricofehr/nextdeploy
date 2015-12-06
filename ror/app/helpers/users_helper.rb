# Stores IO functions for user Class
#
# @author Eric Fehr (eric.fehr@publicis-modem.fr, @github: ricofehr)
module UsersHelper

  # Delete key files
  #
  # No param
  # No return
  def delete_keyfiles
    Rails.logger.warn "rm -f sshkeys/#{self.email}*"
    Rails.logger.warn "rm -f vpnkeys/#{self.email}*"
    system("rm -f sshkeys/#{self.email}*")
    system("rm -f vpnkeys/#{self.email}*")
  end

  # Generate own modem ssh key
  #
  # No param
  # No return
  def generate_authorizedkeys
    # todo: avoid bash cmd
    system('mkdir -p sshkeys')
    system("rm -f sshkeys/#{self.email}.authorized_keys")
    system("touch sshkeys/#{self.email}.authorized_keys")
    # add server nextdeploy public key to authorized_keys
    system("cat ~/.ssh/id_rsa.pub > sshkeys/#{self.email}.authorized_keys")
    Sshkey.admins.each { |k| system("echo #{k.key} >> sshkeys/#{self.email}.authorized_keys") if k.user.id != self.id }
    self.sshkeys.each { |k| system("echo #{k.key} >> sshkeys/#{self.email}.authorized_keys") }
    system("chmod 644 sshkeys/#{self.email}.authorized_keys")
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
    # todo: avoid bash cmd
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
    # todo: avoid bash cmd
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
    template = "vpnkeys/conf/nextdeploy.conf"

    begin
      pattern = IO.read(template)
      pattern.gsub!('%{email}', self.email)
      pattern.gsub!('%{ovpnip}', Rails.application.config.ovpnip)
      pattern.gsub!('%{ovpnport}', Rails.application.config.ovpnport)
    rescue Exception => e
      raise Exceptions::NextDeployException.new("Create nextdeploy.conf file for #{self.email} failed: #{e}")
    end
  end

  # Generate own modem ssh key
  #
  # No param
  # No return
  def generate_sshkey_modem
    # todo: avoid bash cmd
    system("mkdir -p sshkeys")
    system("rm -f sshkeys/#{self.email}")
    system("rm -f sshkeys/#{self.email}.pub")
    system("ssh-keygen -f sshkeys/#{self.email} -N ''")
    system("chmod 644 sshkeys/#{self.email}")
    system("chmod 644 sshkeys/#{self.email}.pub")
    @gitlabapi.add_sshkey(gitlab_id, "modemsshkey", public_sshkey_modem)
  end

  # Copy modem ssh key
  #
  # @param emailsrc (String): user from which we copy modemkeys
  # No return
  def copy_sshkey_modem(emailsrc)
    # todo: avoid bash cmd
    system("mkdir -p sshkeys")
    system("cp -f sshkeys/#{emailsrc} sshkeys/#{self.email}")
    system("cp -f sshkeys/#{emailsrc}.pub sshkeys/#{self.email}.pub")
    system("chmod 644 sshkeys/#{self.email}")
    system("chmod 644 sshkeys/#{self.email}.pub")
  end

  # Move ssh key
  #
  # @param emailsrc (String): old email from same user
  # No return
  def move_sshkey_modem(emailsrc)
    # todo: avoid bash cmd
    system("mkdir -p sshkeys")
    system("mv sshkeys/#{emailsrc} sshkeys/#{self.email}")
    system("mv sshkeys/#{emailsrc}.pub sshkeys/#{self.email}.pub")
    system("rm -f sshkeys/#{emailsrc}")
    system("rm -f sshkeys/#{emailsrc}.pub")
    system("rm -f sshkeys/#{emailsrc}.authorized_keys")
    system("chmod 644 sshkeys/#{self.email}")
    system("chmod 644 sshkeys/#{self.email}.pub")
    generate_authorizedkeys
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