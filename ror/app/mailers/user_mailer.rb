class UserMailer < ActionMailer::Base
  default from: "noreply@#{Rails.application.config.nextdeployuri}"

  # Send credentials to user
  #
  # @param user: User object targeted
  # @param password: Password in plain text
  # no return
  def welcome_email(user, password)
    @user = user
    @password = password
    @url  = "https://ui.#{Rails.application.config.nextdeployuri}/"
    mail(to: @user.email, subject: 'Welcome to NextDeploy')
  end
end
