# Stores IO functions for endpoint Class
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
module EndpointsHelper
  # Lauch bash script for deploy framework
  #
  # No param
  # No return
  def install_endpoint
    # todo: avoid bash cmd
    Rails.logger.warn "/bin/bash /ror/sbin/newendpoint -u #{Rails.application.config.gitlab_prefix} -n #{project.name} -f #{framework.name} -g #{project.gitpath}  -p #{path}"

    # take a lock for project action
    begin
      open("/tmp/project#{project.id}.lock", File::RDWR|File::CREAT) do |f|
        f.flock(File::LOCK_EX)
        system("/bin/bash /ror/sbin/newendpoint -u #{Rails.application.config.gitlab_prefix} -n #{project.name} -f #{framework.name} -g #{project.gitpath} -p #{path}")
      end

    rescue
      raise Exceptions::NextDeployException.new("Lock on create endpoint for #{project.name} failed")
    end
  end
end
