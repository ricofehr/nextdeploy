# Parent class for all controllers
#
# @author Eric Fehr (eric.fehr@publicis-modem.fr, github: ricofehr)
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  skip_before_filter  :verify_authenticity_token

  # auth filtering functions
  before_filter :authenticate_user_from_token!
  before_filter :authenticate_api_v1_user!

  protected

  # check if the current user is included into group "lead developer"
  def check_lead
    return true if @user.lead?

    params[:user_id] = @user.id if params[:user_id] == nil
    if @user.id.to_i != params[:user_id].to_i
      raise Exceptions::MvmcApiException.new("Access forbidden for this user")
    end
  end

  # check if the current user is included into group "admin"
  def check_admin
    return true if @user.admin?

    params[:user_id] = @user.id if params[:user_id] == nil
    if @user.id.to_i != params[:user_id].to_i
       raise Exceptions::MvmcException.new("Access forbidden for this user")
    end
  end

  # check right about current user
  def only_me
    if only_admin
      true
    elsif @user.id.to_i == params[:user_id].to_i
      true
    else
      false
    end
  end

  # check right about admin user
  def only_admin
    if ! @user.admin?
      raise Exceptions::GitlabApiException.new("Access forbidden for this user")
    end

    true
  end

  private

  # signin process
  def authenticate_user_from_token!
    authenticate_with_http_token do |user_token, options|
      @user = user_token && User.find_by_authentication_token(user_token)

      if @user
        sign_in @user, store: false
      end
    end
  end
end
