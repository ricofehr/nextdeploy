# Stores IO functions for user Class
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
module UsersHelper

  # Delete key files
  #
  def delete_keyfiles
    Rails.logger.warn("rm -f sshkeys/#{email}*")
    system("rm -f sshkeys/#{email.shellescape}*")

    Rails.logger.warn("rm -f vpnkeys/#{email}*")
    system("rm -f vpnkeys/#{email.shellescape}*")
  end

  # Upload authorized_keys updated to the active vm for the user
  #
  # @raise [NextDeployException] if errors occurs during lock handling
  def update_authorizedkeys

    # returnn if no projects
    return unless projects

    begin
      open("/tmp/user#{id}.lock", File::RDWR|File::CREAT) do |f|
        f.flock(File::LOCK_EX)

        if lead?
          vms_target = projects.flat_map(&:vms).uniq
        else
          vms_target = vms
        end

        vms_target.each do |k|
          k.generate_authorizedkeys
        end
      end

    rescue
      raise Exceptions::NextDeployException.new("Lock on uploadauthkeys for #{email} failed")
    end

  end

  # Generate own openvpn key
  #
  # @raise [NextDeployException] if errors occurs during lock handling
  def generate_openvpn_keys
    begin
      open("/tmp/user#{id}.lock", File::RDWR|File::CREAT) do |f|
        f.flock(File::LOCK_EX)

        system("cd vpnkeys/bin && source ./vars && KEY_EMAIL=#{email.shellescape} ./build-key #{email.shellescape}")
      end

    rescue
      raise Exceptions::NextDeployException.new("Lock on genopenvpnkeys for #{email} failed")
    end
  end

  # Get server certificate
  #
  def openvpn_ca
    File.open("vpnkeys/ca.crt", "rb").read
  end

  # Get own vpn key
  #
  def openvpn_key
    generate_openvpn_keys unless File.file?("vpnkeys/#{email}.key") && File.file?("vpnkeys/#{email}.csr")
    File.open("vpnkeys/#{email}.key", "rb").read
  end

  # Get own vpn key
  #
  def openvpn_crt
    generate_openvpn_keys unless File.file?("vpnkeys/#{email}.key") && File.file?("vpnkeys/#{email}.csr")
    File.open("vpnkeys/#{email}.crt", "rb").read
  end

  # Generate openvpn conf
  #
  # @raise [NextDeployException] if errors occurs during file reading
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
  # @raise [NextDeployException] if errors occurs during lock handling
  def generate_sshkey_modem

    begin
      open("/tmp/user#{id}.lock", File::RDWR|File::CREAT) do |f|
        f.flock(File::LOCK_EX)

        system("mkdir -p sshkeys")
        system("rm -f sshkeys/#{email.shellescape}")
        system("rm -f sshkeys/#{email.shellescape}.pub")
        system("ssh-keygen -f sshkeys/#{email.shellescape} -N ''")
        system("chmod 644 sshkeys/#{email.shellescape}")
        system("chmod 644 sshkeys/#{email.shellescape}.pub")

        gitlabapi = Apiexternal::Gitlabapi.new
        gitlabapi.add_sshkey(gitlab_id, "modemsshkey", public_sshkey_modem)
    end

    rescue
      raise Exceptions::NextDeployException.new("Lock on gensshkeymodem for #{email} failed")
    end
  end

  # Copy modem ssh key
  #
  # @param emailsrc [String] user from which we copy modemkeys
  # @raise [NextDeployException] if errors occurs during lock handling
  def copy_sshkey_modem(emailsrc)

    begin
      open("/tmp/user#{id}.lock", File::RDWR|File::CREAT) do |f|
        f.flock(File::LOCK_EX)

        system("mkdir -p sshkeys")
        system("cp -f sshkeys/#{emailsrc.shellescape} sshkeys/#{email.shellescape}")
        system("cp -f sshkeys/#{emailsrc.shellescape}.pub sshkeys/#{email.shellescape}.pub")
        system("chmod 644 sshkeys/#{email.shellescape}")
        system("chmod 644 sshkeys/#{email.shellescape}.pub")
      end

    rescue
      raise Exceptions::NextDeployException.new("Lock on copysshkeymodem for #{email} failed")
    end
  end

  # Move ssh key
  #
  # @param emailsrc [String] old email from same user
  # @raise [NextDeployException] if errors occurs during lock handling
  def move_sshkey_modem(emailsrc)

    begin
      open("/tmp/user#{id}.lock", File::RDWR|File::CREAT) do |f|
        f.flock(File::LOCK_EX)

        system("mkdir -p sshkeys")
        system("mv sshkeys/#{emailsrc.shellescape} sshkeys/#{email.shellescape}")
        system("mv sshkeys/#{emailsrc.shellescape}.pub sshkeys/#{email.shellescape}.pub")
        system("rm -f sshkeys/#{emailsrc.shellescape}")
        system("rm -f sshkeys/#{emailsrc.shellescape}.pub")
        system("chmod 644 sshkeys/#{email.shellescape}")
        system("chmod 644 sshkeys/#{email.shellescape}.pub")
    end

    rescue
      raise Exceptions::NextDeployException.new("Lock on movesshkeys for #{email} failed")
    end
  end

  # Get private own modem ssh key
  #
  def private_sshkey_modem
    generate_sshkey_modem unless File.file?("sshkeys/#{email}") && File.file?("sshkeys/#{email}.pub")
    File.open("sshkeys/#{email}", "rb").read
  end

  # Get public own modem ssh key
  #
  def public_sshkey_modem
    generate_sshkey_modem unless File.file?("sshkeys/#{email}") && File.file?("sshkeys/#{email}.pub")
    File.open("sshkeys/#{email}.pub", "rb").read
  end
end
