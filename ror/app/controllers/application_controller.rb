# Parent class for all controllers
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class ApplicationController < ActionController::Base
  # include serializers class. Needed for serialization_scope parameter
  include ActionController::Serialization

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  skip_before_filter  :verify_authenticity_token

  # auth filtering functions
  before_filter :authenticate_user_from_token!
  before_filter :authenticate_api_v1_user!

  # access to controller object from serializers
  serialization_scope :view_context
  helper_method :current_user

  protected

  # check if the current user is included into group "lead developer"
  def check_lead
    if ! @user
      raise Exceptions::NextDeployException.new("Access forbidden for this user")
    end

    return true if @user.lead?
    params[:user_id] = @user.id
  end

  # check if the current user is included into group "admin"
  def check_admin
    if ! @user
      raise Exceptions::NextDeployException.new("Access forbidden for this user")
    end

    return true if @user.admin?
    params[:user_id] = @user.id
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
      raise Exceptions::NextDeployException.new("Access forbidden for this user")
    end

    true
  end

  # check right about lead user
  def only_lead
    if ! @user.lead?
      raise Exceptions::NextDeployException.new("Access forbidden for this user")
    end

    true
  end

  private

  # permit current suer access from serializer objects
  def current_user
    @user
  end

  # signin process
  def authenticate_user_from_token!
    authenticate_with_http_token do |user_token, options|
      @user = user_token && User.find_by_authentication_token(user_token)
      sign_in(:api_v1_user, @user) if @user
    end
  end
end
