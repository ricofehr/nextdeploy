# Stores IO functions for project Class
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
module ProjectsHelper
  # Lauch bash script for create root folder
  #
  def create_rootfolder
    gitlab_prefix = Rails.application.config.gitlab_prefix
    bash_cmd = "/bin/bash /ror/sbin/newproject -u #{gitlab_prefix.shellescape} " +
               "-n #{name.shellescape} -g #{gitpath.shellescape}"

    Rails.logger.warn(bash_cmd)
    system(bash_cmd)
  end

  # Remove gitfolder
  #
  # @raise an exception if errors occurs during lock handling
  def remove_gitpath
    # temporary folder for init the project
    # it must be cleared during the creation process
    if name && name.length > 0
      # take a lock for project action
      begin
        open("/tmp/project#{id}.lock", File::RDWR|File::CREAT) do |f|
          f.flock(File::LOCK_EX)

          system("rm -rf #{Rails.application.config.project_initpath}/#{name.shellescape}")
        end

      rescue
        raise Exceptions::NextDeployException.new("Lock on remove gitpath for #{name} failed")
      end

    end

    true
  end

  # Lauch bash script for create ftp user for assets and dump
  #
  # @raise an exception if errors occurs during lock handling
  def create_ftp
    # generate password for ftp
    (password && password.length > 0) ? (ftppasswd = password[0..7]) : (ftppasswd = 'nextdeploy')

    bash_cmd = "sudo /usr/local/bin/./nextdeploy-addftp #{gitpath.shellescape}"

    # take a lock for project action
    begin
      open("/tmp/project#{id}.lock", File::RDWR|File::CREAT) do |f|
        f.flock(File::LOCK_EX)

        Rails.logger.warn("#{bash_cmd} xxxxxxx")
        system("#{bash_cmd} #{ftppasswd.shellescape}")
      end

    rescue
      raise Exceptions::NextDeployException.new("Lock on create_ftp for #{name} failed")
    end

    true
  end

  # Launch bash script for delete ftp user for assets and dump
  #
  # @raise an exception if errors occurs during lock handling
  def remove_ftp
    bash_cmd = "sudo /usr/local/bin/./nextdeploy-rmftp #{gitpath.shellescape}"

    begin
      open("/tmp/project#{id}.lock", File::RDWR|File::CREAT) do |f|
        f.flock(File::LOCK_EX)

        Rails.logger.warn(bash_cmd)
        system(bash_cmd)
      end

    rescue
      raise Exceptions::NextDeployException.new("Lock on remove_ftp for #{name} failed")
    end

    # remove project lock file
    system("rm -f /tmp/project#{id}.lock")

    true
  end

  # Lauch bash script for update ftp password for assets and dump
  #
  # @raise an exception if errors occurs during lock handling
  def update_ftp
    # generate password for ftp
    (password && password.length > 0) ? (ftppasswd = password[0..7]) : (ftppasswd = 'nextdeploy')

    bash_cmd = "sudo /usr/local/bin/./nextdeploy-updftp #{gitpath.shellescape}"

    begin
      open("/tmp/project#{id}.lock", File::RDWR|File::CREAT) do |f|
        f.flock(File::LOCK_EX)

        Rails.logger.warn("#{bash_cmd} xxxxxxx")
        system("#{bash_cmd} #{ftppasswd.shellescape}")
      end

    rescue
      raise Exceptions::NextDeployException.new("Lock on update_ftp for #{name} failed")
    end

    true
  end
end
