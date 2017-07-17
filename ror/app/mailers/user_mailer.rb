# Manages welcome and user creation alerts sending by mail
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class UserMailer < ActionMailer::Base
  default from: "noreply@#{Rails.application.config.nextdeployuri}"

  # Send credentials to user
  #
  # @param user [User] User object targeted
  # @param password [String] Password in plain text
  def welcome_email(user, password)
    @user = user
    @password = password
    @url  = "https://ui.#{Rails.application.config.nextdeployuri}/"
    mail(to: @user.email, subject: 'Welcome to NextDeploy')
  end

  # Send alert to admin when a new user is creating by any Lead
  #
  # @param user [User] New User object targeted
  # @param admin [User] Admin user
  # @param lead [User] Lead user
  def create_user(user, admin, lead)
    @user = user
    @admin = admin
    @lead = lead
    @url  = "https://ui.#{Rails.application.config.nextdeployuri}/"
    mail(to: @admin.email, subject: "[NextDeploy] #{@user.email} added")
  end
end
