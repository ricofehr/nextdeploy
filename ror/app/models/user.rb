# The User object
#
# @author Eric Fehr (eric.fehr@publicis-modem.fr, github: ricofehr)
class User < ActiveRecord::Base
  # An Heleer module contains IO functions
  include UsersHelper

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :user_project, dependent: :destroy
  has_many :projects, through: :user_project
  has_many :vms, dependent: :destroy
  has_many :sshkeys, dependent: :destroy
  #attr_accessor :email, :authentication_token

  belongs_to :group

  # validates conditions
  validates :email, presence: true, length: {maximum: 255}, uniqueness: { case_sensitive: false }

  # Some hooks before chnages on user object
  before_save :ensure_authentication_token

  before_create :init_user, :generate_sshkey_modem, :generate_authorizedkeys, :generate_authentication_token, :generate_openvpn_keys
  before_update :update_user
  before_destroy :purge_user

  after_initialize :init_gitlabapi

  # gitlabapi object
  @gitlabapi = nil

  # Return current token and generates one before it if needed
  #
  # No param
  # @return [String] token
  def ensure_authentication_token
    self.authentication_token ||= generate_authentication_token
  end

  # Return gitlab username
  #
  # No param
  # @return [String] gitlab username compliant
  def gitlab_user
    self.email.gsub(/@.*/,'')
  end

  # Return group access_level
  #
  # No param
  # @return [integer] group accesslevel
  def access_level
    self.group.access_level
  end

  # Return true if admin
  #
  # No param
  # @return [Boolean] if admin
  def admin?
    self.group.admin?
  end

  # Return true if lead or admin
  #
  # No param
  # @return [Boolean] if admin
  def lead?
    self.group.lead?
  end

  # Return true if guest
  #
  # No param
  # @return [Boolean] if guest
  def guest?
    self.group.access_level == 10
  end

  private

  # Set gitlabapi object
  #
  # No param
  # No return
  def init_gitlabapi
    @gitlabapi = Apiexternal::Gitlabapi.new
  end

  # Create the user to gitlab, set gitlab_id attribute
  #
  # No param
  # No return
  def init_user
    begin
      self.gitlab_id = @gitlabapi.create_user(self.email, self.password, self.gitlab_user)
      self.projects.each {|project| @gitlabapi.add_user_to_project(project.gitlab_id, self.gitlab_id, self.access_level)}
    rescue Exceptions::MvmcException => me
      me.log
    end
  end

  # Update the user to gitlab
  #
  # No param
  # No return
  def update_user
    begin
      @gitlabapi.update_user(self.gitlab_id, self.email, self.password, self.gitlab_user)
      self.projects.each {|project| @gitlabapi.add_user_to_project(project.gitlab_id, self.gitlab_id, self.access_level)}
    rescue Exceptions::MvmcException => me
      me.log
    end
  end

  # Purge current user from gitlab
  #
  # No param
  # No return
  def purge_user
    begin
      @gitlabapi.delete_user(self.gitlab_id)
    rescue Exceptions::MvmcException => me
      me.log
    end

    delete_keyfiles
  end

  # Generate a token for Devise library
  #
  # No param
  # No return
  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
    end
  end
end
