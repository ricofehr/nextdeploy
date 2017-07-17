# Manages vm installation alert sending by mail
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class VmMailer < ActionMailer::Base
  default from: "noreply@#{Rails.application.config.nextdeployuri}"

  # Send alert when a vm is installed and ready to work
  #
  # @param dest [String] Mail destination user
  # @param project [Project] Vm project
  # @param user [User] Vm user
  # @param commit [Commit] Vm commit
  # @param uris [Array<Uri>] Vm uris array
  # @param htlogin [String] basicauth login
  # @param htpassword [String] basicauth password
  def vm_ready(dest, project, user, commit, uris, htlogin, htpassword)
    @project = project
    @user = user
    @commit = commit
    @uris = uris.select { |uri| uri.framework.name != 'NoWeb' }
    @htlogin = htlogin
    @htpassword = htpassword
    @url  = "https://ui.#{Rails.application.config.nextdeployuri}/"
    mail(to: dest.email, subject: "[NextDeploy] Vm installed")
  end
end
