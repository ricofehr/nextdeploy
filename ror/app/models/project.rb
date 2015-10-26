# The Project object
#
# @author Eric Fehr (eric.fehr@publicis-modem.fr, github: ricofehr)
class Project < ActiveRecord::Base
  # IO function are included into helpers module
  include ProjectsHelper

  belongs_to :brand
  belongs_to :framework
  belongs_to :systemimagetype

  has_many :project_technos, dependent: :destroy
  has_many :prefix_dns_s, dependent: :destroy
  has_many :technos, through: :project_technos

  has_many :user_project, dependent: :destroy
  has_many :users, through: :user_project

  has_many :project_vmsize, dependent: :destroy
  has_many :vmsizes, through: :project_vmsize

  has_many :vms, dependent: :destroy

  # some properties are mandatory and must be well-formed
  validates :name, :brand_id, :framework_id, :systemimagetype_id, :gitpath, presence: true
  validates :brand_id, :framework_id, numericality: {only_integer: true, greater_than: 0}

  # Git repository dependence
  before_create :init_gitlabapi, :create_git, :create_ftp
  before_destroy :init_gitlabapi, :delete_git, :remove_ftp

  @gitlabapi = nil

  private

  # Init gitlabapi object
  #
  # No param
  # No return
  def init_gitlabapi
    @gitlabapi = Apiexternal::Gitlabapi.new
  end

  # Init branchs array
  #
  # No param
  # No return
  def branches
      Branche.all(self.id)
  end


  # Create gitlab project from current object attributes
  #
  # No param
  # No return
  def create_git
    branchs = ['develop', 'hotfixes', 'release']

    begin
      self.gitlab_id = @gitlabapi.create_project(self.name, self.gitpath)
      create_rootfolder
      branchs.each {|branch| @gitlabapi.create_branch(self.gitlab_id, branch, 'master')}
      @gitlabapi.protect_branch(self.gitlab_id, 'master')
      self.users.each {|user| @gitlabapi.add_user_to_project(self.gitlab_id, user.gitlab_id, user.access_level)}
    rescue Exceptions::MvmcException => me
      me.log
    end
  end

  # Delete gitlab project
  #
  # No param
  # No return
  def delete_git
    begin
      @gitlabapi.delete_project(self.gitlab_id)
    rescue Exceptions::MvmcException => me
      me.log
    end
    remove_gitpath
  end
end
