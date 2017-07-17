# Stores IO functions for endpoint Class
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
module EndpointsHelper
  # Lauch bash script for deploy framework
  #
  # @raise [NextDeployException] if errors occurs during lock handling
  def install_endpoint
    gitlab_prefix = Rails.application.config.gitlab_prefix

    bash_cmd = "/bin/bash /ror/sbin/newendpoint -u #{gitlab_prefix} -n #{project.name} " +
               "-f #{framework.name} -g #{project.gitpath} -p #{path}"

    # take a lock for project action
    begin
      open("/tmp/project#{project.id}.lock", File::RDWR|File::CREAT) do |f|
        f.flock(File::LOCK_EX)

        Rails.logger.warn(bash_cmd)
        # HACK no escaped bash command !
        system(bash_cmd)
      end

    rescue
      raise Exceptions::NextDeployException.new("Lock on create endpoint for #{project.name} failed")
    end
  end
end
