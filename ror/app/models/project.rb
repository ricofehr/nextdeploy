# The Project object
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class Project < ActiveRecord::Base
  # IO function are included into helpers module
  include ProjectsHelper

  belongs_to :brand
  belongs_to :framework
  belongs_to :owner, class_name: "User", foreign_key: "owner_id", inverse_of: :own_projects

  has_many :project_technos, dependent: :destroy
  has_many :technos, through: :project_technos
  has_many :prefix_dns_s, dependent: :destroy

  has_many :user_project, dependent: :destroy
  has_many :users, through: :user_project, inverse_of: :projects

  has_many :project_vmsize, dependent: :destroy
  has_many :vmsizes, through: :project_vmsize

  has_many :project_systemimage, dependent: :destroy
  has_many :systemimages, through: :project_systemimage

  has_many :vms, dependent: :destroy

  # some properties are mandatory and must be well-formed
  validates :name, :brand_id, :framework_id, :systemimage_ids, :gitpath, presence: true
  validates :brand_id, :framework_id, numericality: {only_integer: true, greater_than: 0}

  # Git repository dependence
  before_create :create_git, :create_ftp
  before_update :update_git, :update_ftp
  before_destroy :delete_git, :remove_ftp

  # Flush cache for branches
  #
  # No param
  # No return
  def flushCache
    Rails.cache.delete("projects/#{id}/branchs")
  end

  private

  # Init branchs array
  #
  # No param
  # No return
  def branches
      Rails.cache.fetch("projects/#{id}/branchs", expires_in: 144.hours) do
        Branche.all(id)
      end
  end

  # Create gitlab project from current object attributes
  #
  # No param
  # No return
  def create_git
    branchs = ['develop', 'hotfixes', 'release']
    gitlabapi = Apiexternal::Gitlabapi.new

    begin
      self.gitlab_id = gitlabapi.create_project(name, gitpath)
      create_rootfolder
      branchs.each {|branch| gitlabapi.create_branch(gitlab_id, branch, 'master')}
      gitlabapi.unprotect_branch(gitlab_id, 'master')
      users.each {|user| gitlabapi.add_user_to_project(gitlab_id, user.gitlab_id, user.access_level)}
    rescue Exceptions::NextDeployException => me
      me.log
    end
  end

  # Delete gitlab project
  #
  # No param
  # No return
  def delete_git
    gitlabapi = Apiexternal::Gitlabapi.new

    begin
      gitlabapi.delete_project(gitlab_id)
    rescue Exceptions::NextDeployException => me
      me.log
    end
    remove_gitpath
  end

  # Update the project-user association
  #
  # No param
  # No return
  def update_git
    gitlabapi = Apiexternal::Gitlabapi.new

    begin
      users_g = gitlabapi.get_project_users(gitlab_id)
      # remove user to project if needed
      users_g.each do |user|
        unless users.any? { |usr| usr.gitlab_id == user.id }
          gitlabapi.delete_user_to_project(gitlab_id, user.id)
        end
      end

      users.each do |user|
        unless users_g.any? { |usr| usr.id == user.gitlab_id }
          gitlabapi.add_user_to_project(gitlab_id, user.gitlab_id, user.access_level)
        end
      end
    rescue Exceptions::NextDeployException => me
      me.log
    end
  end
end