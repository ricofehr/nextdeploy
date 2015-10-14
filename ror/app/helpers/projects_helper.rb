# Stores IO functions for project Class
#
# @author Eric Fehr (eric.fehr@publicis-modem.fr, @github: ricofehr)
module ProjectsHelper
  # Lauch bash script for create root folder and deploy framework
  #
  # No param
  # No return
  def create_rootfolder
    # todo: avoid bash cmd
    Rails.logger.warn "/bin/bash /ror/sbin/newproject -n #{self.name} -f #{self.framework.name} -g #{self.gitpath}"
    system("/bin/bash /ror/sbin/newproject -n #{self.name} -f #{self.framework.name} -g #{self.gitpath}")
  end

  # Remove gitfolder
  #
  # No param
  # No return
  def remove_gitpath
    # temporary folder for init the project
    # it must be cleared during the creation process
    # todo: avoid bash cmd
    if self.name && self.name.length > 0
      system("rm -rf #{Rails.application.config.project_initpath}/#{self.name}")
    end
  end
end
