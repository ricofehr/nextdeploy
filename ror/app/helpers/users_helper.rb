# Stores IO functions for user Class
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
module UsersHelper

  # Delete key files
  #
  # No param
  # No return
  def delete_keyfiles
    Rails.logger.warn "rm -f sshkeys/#{email}*"
    Rails.logger.warn "rm -f vpnkeys/#{email}*"
    system("rm -f sshkeys/#{email}*")
    system("rm -f vpnkeys/#{email}*")
  end

  # Generate own modem ssh key
  #
  # No param
  # No return
  def generate_authorizedkeys

    begin
      open("/tmp/user#{id}.lock", File::RDWR|File::CREAT) do |f|
        f.flock(File::LOCK_EX)
    
        # todo: avoid bash cmd
        system('mkdir -p sshkeys')
        system("rm -f sshkeys/#{email}.authorized_keys")
        system("touch sshkeys/#{email}.authorized_keys")
        # add server nextdeploy public key to authorized_keys
        system("cat ~/.ssh/id_rsa.pub > sshkeys/#{email}.authorized_keys")
        Sshkey.admins.each { |k| system("echo #{k.key} >> sshkeys/#{email}.authorized_keys") if k.user.id != id }
        sshkeys.each { |k| system("echo #{k.key} >> sshkeys/#{email}.authorized_keys") }
        system("chmod 644 sshkeys/#{email}.authorized_keys")
      end

    rescue
      raise Exceptions::NextDeployException.new("Lock on authkeys for #{email} failed")
    end
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

    begin
      open("/tmp/user#{id}.lock", File::RDWR|File::CREAT) do |f|
        f.flock(File::LOCK_EX)

        # todo: avoid bash cmd
        vms.each do |k|
          Rails.logger.warn "rsync -avzPe \"ssh -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null\" sshkeys/#{email}.authorized_keys modem@#{k.floating_ip}:~/.ssh/authorized_keys"
          system("rsync -avzPe \"ssh -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null\" sshkeys/#{email}.authorized_keys modem@#{k.floating_ip}:~/.ssh/authorized_keys")
        end
    end

    rescue
      raise Exceptions::NextDeployException.new("Lock on uploadauthkeys for #{email} failed")
    end

  end

  # Generate own openvpn key
  #
  # No param
  # No return
  def generate_openvpn_keys
    begin
      open("/tmp/user#{id}.lock", File::RDWR|File::CREAT) do |f|
        f.flock(File::LOCK_EX)
        # todo: avoid bash cmd
        system("cd vpnkeys/bin && source ./vars && KEY_EMAIL=#{email} ./build-key #{email}")
    end

    rescue
      raise Exceptions::NextDeployException.new("Lock on genopenvpnkeys for #{email} failed")
    end
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
    generate_openvpn_keys unless File.file?("vpnkeys/#{email}.key") && File.file?("vpnkeys/#{email}.csr")
    File.open("vpnkeys/#{email}.key", "rb").read
  end

  # Get own vpn key
  #
  # No param
  # No return
  def openvpn_crt
    generate_openvpn_keys unless File.file?("vpnkeys/#{email}.key") && File.file?("vpnkeys/#{email}.csr")
    File.open("vpnkeys/#{email}.crt", "rb").read
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
      pattern.gsub!('%{email}', email)
      pattern.gsub!('%{ovpnip}', Rails.application.config.ovpnip)
      pattern.gsub!('%{ovpnport}', Rails.application.config.ovpnport)
    rescue Exception => e
      raise Exceptions::NextDeployException.new("Create nextdeploy.conf file for #{email} failed: #{e}")
    end
  end

  # Generate own modem ssh key
  #
  # No param
  # No return
  def generate_sshkey_modem

    begin
      open("/tmp/user#{id}.lock", File::RDWR|File::CREAT) do |f|
        f.flock(File::LOCK_EX)

        # todo: avoid bash cmd
        system("mkdir -p sshkeys")
        system("rm -f sshkeys/#{email}")
        system("rm -f sshkeys/#{email}.pub")
        system("ssh-keygen -f sshkeys/#{email} -N ''")
        system("chmod 644 sshkeys/#{email}")
        system("chmod 644 sshkeys/#{email}.pub")

        gitlabapi = Apiexternal::Gitlabapi.new
        gitlabapi.add_sshkey(gitlab_id, "modemsshkey", public_sshkey_modem)
    end

    rescue
      raise Exceptions::NextDeployException.new("Lock on gensshkeymodem for #{email} failed")
    end
  end

  # Copy modem ssh key
  #
  # @param emailsrc (String): user from which we copy modemkeys
  # No return
  def copy_sshkey_modem(emailsrc)
   
    begin
      open("/tmp/user#{id}.lock", File::RDWR|File::CREAT) do |f|
        f.flock(File::LOCK_EX)
        
        # todo: avoid bash cmd
        system("mkdir -p sshkeys")
        system("cp -f sshkeys/#{emailsrc} sshkeys/#{email}")
        system("cp -f sshkeys/#{emailsrc}.pub sshkeys/#{email}.pub")
        system("chmod 644 sshkeys/#{email}")
        system("chmod 644 sshkeys/#{email}.pub")
      end

    rescue
      raise Exceptions::NextDeployException.new("Lock on copysshkeymodem for #{email} failed")
    end
  end

  # Move ssh key
  #
  # @param emailsrc (String): old email from same user
  # No return
  def move_sshkey_modem(emailsrc)

    begin
      open("/tmp/user#{id}.lock", File::RDWR|File::CREAT) do |f|
        f.flock(File::LOCK_EX)

        # todo: avoid bash cmd
        system("mkdir -p sshkeys")
        system("mv sshkeys/#{emailsrc} sshkeys/#{email}")
        system("mv sshkeys/#{emailsrc}.pub sshkeys/#{email}.pub")
        system("rm -f sshkeys/#{emailsrc}")
        system("rm -f sshkeys/#{emailsrc}.pub")
        system("rm -f sshkeys/#{emailsrc}.authorized_keys")
        system("chmod 644 sshkeys/#{email}")
        system("chmod 644 sshkeys/#{email}.pub")
    end

    rescue
      raise Exceptions::NextDeployException.new("Lock on movesshkeys for #{email} failed")
    end

    generate_authorizedkeys
  end

  # Get private own modem ssh key
  #
  # No param
  # No return
  def private_sshkey_modem
    generate_sshkey_modem unless File.file?("sshkeys/#{email}") && File.file?("sshkeys/#{email}.pub")
    File.open("sshkeys/#{email}", "rb").read
  end

  # Get public own modem ssh key
  #
  # No param
  # No return
  def public_sshkey_modem
    generate_sshkey_modem unless File.file?("sshkeys/#{email}") && File.file?("sshkeys/#{email}.pub")
    File.open("sshkeys/#{email}.pub", "rb").read
  end
end