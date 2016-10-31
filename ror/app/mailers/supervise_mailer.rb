class SuperviseMailer < ActionMailer::Base
  default from: "noreply@#{Rails.application.config.nextdeployuri}"

  # Send supervie alert to user
  #
  # @param user: User object targeted
  # @param vm: Vm object targeted by alert
  # @param techno: Techno targeted by alert
  # @param status: 0 => KO, 1 => OK
  # no return
  def supervise_email(user, vm, techno, status)
    @user = user
    @vm = vm
    @techno = techno
    @technotype = techno.technotype
    @status = status
    @url  = "https://ui.#{Rails.application.config.nextdeployuri}/"
    subject = status ? 'Problem resolved in your vm' : 'Problem detect in your vm'
    mail(to: @user.email, subject: 'Problem detected in your vm')
  end
end
