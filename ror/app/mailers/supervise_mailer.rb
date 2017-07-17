# Manages supervise alerts sending by mail
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class SuperviseMailer < ActionMailer::Base
  default from: "noreply@#{Rails.application.config.nextdeployuri}"

  # Send supervie alert to user
  #
  # @param user [User] User object targeted
  # @param vm [Vm] Vm object targeted by alert
  # @param techno [Techno] Techno targeted by alert
  # @param status [Boolean] 0 => KO, 1 => OK
  def supervise_email(user, vm, techno, status)
    @user = user
    @vm = vm
    @techno = techno
    @technotype = techno.technotype
    @status = status
    @url  = "https://ui.#{Rails.application.config.nextdeployuri}/"
    subject = status ? 'Problem resolved in your vm' : 'Problem detected in your vm'
    mail(to: @user.email, subject: subject)
  end
end
