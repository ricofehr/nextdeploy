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
  end

  # Generate own modem ssh key
  #
  # No param
  # No return
  def generate_authorizedkeys
    system('mkdir -p sshkeys')
    system("rm -f sshkeys/#{self.email}.authorized_keys")
    system("touch sshkeys/#{self.email}.authorized_keys")
    Sshkey.admins.each { |k| system("echo #{k.key} >> sshkeys/#{self.email}.authorized_keys") }
    self.sshkeys.each { |k| system("echo #{k.key} >> sshkeys/#{self.email}.authorized_keys") }
    system("chmod 777 sshkeys/*")
  end

  # Generate own modem ssh key
  #
  # No param
  # No return
  def generate_sshkey_modem
    system("mkdir -p sshkeys")
    system("ssh-keygen -f sshkeys/#{self.email} -N ''")
    system("chmod 777 sshkeys/*")
    #@gitlabapi.delete_sshkey(self.name, self.modemkey) if self.modemkey
    #self.modemkey = 
    @gitlabapi.add_sshkey(gitlab_user, "modemsshkey", public_sshkey_modem)
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