# Stores properties about ssh key and execute background command for gitlab / cloud.
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class Sshkey < ActiveRecord::Base
  belongs_to :user

  # some hooks befor key changes
  before_create :init_sshkey
  before_destroy :purge_sshkey
  before_update :reset_sshkey

  # some hooks after key changes
  after_create :update_authorizedkeys
  after_destroy :update_authorizedkeys
  after_update :update_authorizedkeys

  # some properties are mandatory and must be well-formed
  validates :name, :key, :user_id, presence: true


  #get all sshkey for admins users
  scope :admins, ->(){ joins(:user => :group).where('groups.access_level' => 50) }

  private


  # add sshkey to openstack and gitlab
  #
  # No param
  # No return
  def init_sshkey
    osapi = Apiexternal::Osapi.new
    gitlabapi = Apiexternal::Gitlabapi.new

    begin
      #openstack side
      osapi.add_sshkey(name, key)

      #gitlab side
      self.gitlab_id = gitlabapi.add_sshkey(user.gitlab_id, name, key)
    rescue Exceptions::NextDeployException => me
      me.log
    end
  end

  # write new version of authorizedkeys
  #
  # No param
  # No return
  def update_authorizedkeys
      #regenerate authorizedkeys
      user.generate_authorizedkeys
      user.generate_all_authorizedkeys if user.admin?
      user.upload_authorizedkeys
  end


  # reset sshkey to openstack and gitlab
  #
  # No param
  # No return
  def reset_sshkey
    osapi = Apiexternal::Osapi.new
    gitlabapi = Apiexternal::Gitlabapi.new

    begin
      #openstack side
      osapi.delete_sshkey(name)
      osapi.add_sshkey(name, key)

      #gitlab side
      gitlabapi.delete_sshkey(user.gitlab_id, gitlab_id)
      self.gitlab_id = gitlabapi.add_sshkey(user.gitlab_id, name, key)
    rescue Exceptions::NextDeployException => me
      me.log
    end
  end

  # remove sshkey to openstack and gitlab
  #
  # No param
  # No return
  def purge_sshkey
    osapi = Apiexternal::Osapi.new
    gitlabapi = Apiexternal::Gitlabapi.new

    begin
      #openstack side
      osapi.delete_sshkey(name)

      #gitlab side
      gitlabapi.delete_sshkey(user.gitlab_id, gitlab_id)
    rescue Exceptions::NextDeployException => me
      me.log
    end
  end
end
