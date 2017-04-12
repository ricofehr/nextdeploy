class VmMailer < ActionMailer::Base
  default from: "noreply@#{Rails.application.config.nextdeployuri}"

  # Send alert when a vm is installed and ready to work
  #
  # @param dest: Mail destination user
  # @param project: Vm project
  # @param user: Vm user
  # @param commit: Vm commit
  # @param uris: Vm uris array
  # no return
  def vm_ready(dest, project, user, commit, uris, htlogin, htpassword)
    @project = project
    @user = user
    @commit = commit
    @uris = uris
    @htlogin = htlogin
    @htpassword = htpassword
    @url  = "https://ui.#{Rails.application.config.nextdeployuri}/"
    mail(to: dest.email, subject: "[NextDeploy] Vm installed")
  end
end
