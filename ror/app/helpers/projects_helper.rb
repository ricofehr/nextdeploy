# Stores IO functions for project Class
#
# @author Eric Fehr (eric.fehr@publicis-modem.fr, @github: ricofehr)
module ProjectsHelper
  # Lauch bash script for create root folder and deploy framework
  #
  # No param
  # No return
  def create_rootfolder
    %x(/bin/bash /ror/sbin/newproject -n #{self.name} -f #{self.framework.name} -g #{self.gitpath})
  end

  # Remove gitfolder
  #
  # No param
  # No return
  def remove_gitpath
    if self.gitpath && self.gitpath.length > 0
      system("sudo -u git rm -rf #{Rails.application.config.gitlab_rootpath}/#{self.gitpath}.git")
      system("sudo -u git rm -rf #{Rails.application.config.gitlab_rootpath}/#{self.gitpath}.wiki.git")
    end

    if self.name && self.name.length > 0
      system("rm -rf #{Rails.application.config.project_initpath}/#{self.name}")
    end
  end
end
