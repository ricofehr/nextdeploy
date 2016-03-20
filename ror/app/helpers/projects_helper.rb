# Stores IO functions for project Class
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
module ProjectsHelper
  # Lauch bash script for create root folder and deploy framework
  #
  # No param
  # No return
  def create_rootfolder
    # todo: avoid bash cmd
    Rails.logger.warn "/bin/bash /ror/sbin/newproject -u #{Rails.application.config.gitlab_prefix} -n #{name} -f #{framework.name} -g #{gitpath}"
    system("/bin/bash /ror/sbin/newproject -u #{Rails.application.config.gitlab_prefix} -n #{name} -f #{framework.name} -g #{gitpath}")
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
      system("rm -rf #{Rails.application.config.project_initpath}/#{name}")
    end
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
    system("sudo /usr/local/bin/./nextdeploy-addftp #{gitpath} #{ftppasswd}")
  end

  # Lauch bash script for delete ftp user for assets and dump
  #
  # No param
  # No return
  def remove_ftp
    # todo: avoid bash cmd
    Rails.logger.warn "sudo /usr/local/bin/./nextdeploy-rmftp #{gitpath}"
    system("sudo /usr/local/bin/./nextdeploy-rmftp #{gitpath}")
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
    system("sudo /usr/local/bin/./nextdeploy-updftp #{gitpath} #{ftppasswd}")
  end
end
