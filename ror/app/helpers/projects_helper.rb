# Stores IO functions for project Class
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
module ProjectsHelper
  # Lauch bash script for create root folder
  #
  # No param
  # No return
  def create_rootfolder
    # todo: avoid bash cmd
    Rails.logger.warn "/bin/bash /ror/sbin/newproject -u #{Rails.application.config.gitlab_prefix} -n #{name} -g #{gitpath}"
    system("/bin/bash /ror/sbin/newproject -u #{Rails.application.config.gitlab_prefix} -n #{name} -g #{gitpath}")
  end

  # Remove gitfolder
  #
  # No param
  # No return
  def remove_gitpath
    # temporary folder for init the project
    # it must be cleared during the creation process
    # todo: avoid bash cmd
    if name && name.length > 0
      # take a lock for project action
      begin
        open("/tmp/project#{id}.lock", File::RDWR|File::CREAT) do |f|
          f.flock(File::LOCK_EX)
          system("rm -rf #{Rails.application.config.project_initpath}/#{name}")
        end

      rescue
        raise Exceptions::NextDeployException.new("Lock on remove gitpath for #{name} failed")
      end

    end

    true
  end

  # Lauch bash script for create ftp user for assets and dump
  #
  # No param
  # No return
  def create_ftp
    # generate password for ftp
    (password && password.length > 0) ? (ftppasswd = password[0..7]) : (ftppasswd = 'nextdeploy')

    # todo: avoid bash cmd
    Rails.logger.warn "sudo /usr/local/bin/./nextdeploy-addftp #{gitpath} xxxxxxx"

    # take a lock for project action
    begin
      open("/tmp/project#{id}.lock", File::RDWR|File::CREAT) do |f|
        f.flock(File::LOCK_EX)
        system("sudo /usr/local/bin/./nextdeploy-addftp #{gitpath} #{ftppasswd}")
     end

    rescue
      raise Exceptions::NextDeployException.new("Lock on create_ftp for #{name} failed")
    end

    true
  end

  # Lauch bash script for delete ftp user for assets and dump
  #
  # No param
  # No return
  def remove_ftp
    # todo: avoid bash cmd
    Rails.logger.warn "sudo /usr/local/bin/./nextdeploy-rmftp #{gitpath}"

    begin
      open("/tmp/project#{id}.lock", File::RDWR|File::CREAT) do |f|
        f.flock(File::LOCK_EX)
        system("sudo /usr/local/bin/./nextdeploy-rmftp #{gitpath}")
     end

    rescue
      raise Exceptions::NextDeployException.new("Lock on remove_ftp for #{name} failed")
    end

    # remove project lock
    system("rm -f /tmp/project#{id}.lock")

    true
  end

  # Lauch bash script for update ftp password for assets and dump
  #
  # No param
  # No return
  def update_ftp
    # generate password for ftp
    (password && password.length > 0) ? (ftppasswd = password[0..7]) : (ftppasswd = 'nextdeploy')

    # todo: avoid bash cmd
    Rails.logger.warn "sudo /usr/local/bin/./nextdeploy-updftp #{gitpath} xxxxxxx"

    begin
      open("/tmp/project#{id}.lock", File::RDWR|File::CREAT) do |f|
        f.flock(File::LOCK_EX)
        system("sudo /usr/local/bin/./nextdeploy-updftp #{gitpath} #{ftppasswd}")
     end

    rescue
      raise Exceptions::NextDeployException.new("Lock on update_ftp for #{name} failed")
    end

    true
  end
end
