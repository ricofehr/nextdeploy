# The Project object
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class Project < ActiveRecord::Base
  # IO function are included into helpers module
  include ProjectsHelper

  belongs_to :brand
  belongs_to :owner, class_name: "User", foreign_key: "owner_id", inverse_of: :own_projects

  has_many :endpoints, dependent: :destroy
  has_many :project_technos, dependent: :destroy
  has_many :technos, through: :project_technos

  has_many :user_projects, dependent: :destroy
  has_many :users, through: :user_projects, inverse_of: :projects

  has_many :project_vmsizes, dependent: :destroy
  has_many :vmsizes, through: :project_vmsizes

  has_many :project_systemimages, dependent: :destroy
  has_many :systemimages, through: :project_systemimages

  has_many :vms, dependent: :destroy

  # some properties are mandatory and must be well-formed
  validates :name, :brand_id, :systemimage_ids, :gitpath, presence: true
  validates :brand_id, numericality: {only_integer: true, greater_than: 0}

  # Git repository dependence
  before_create :create_git, :create_ftp
  before_update :update_git, :update_ftp
  before_destroy :delete_git, :remove_ftp, prepend: true

  # Flush project branches caching objects
  #
  # @param branch [String]
  def flush_branche(branch)
    Rails.cache.delete("projects/#{id}/branchs")
    Rails.cache.delete("branches/#{id}-#{branch}/commits")
  end

  # Return branches list
  #
  # @return [Array<Branche>]
  def branches
      Rails.cache.fetch("projects/#{id}/branchs", expires_in: 240.hours) do
        Branche.all(id)
      end
  end

  private

  # Create gitlab project from current object attributes
  #
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
