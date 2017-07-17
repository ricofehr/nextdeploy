# Stores properties about ssh key and execute background command for gitlab / cloud.
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class Sshkey < ActiveRecord::Base
  belongs_to :user

  # some hooks befor key changes
  before_create :init_sshkey
  before_destroy :purge_sshkey, prepend: true
  before_update :reset_sshkey

  # some hooks after key changes
  after_create :update_authorizedkeys
  after_destroy :update_authorizedkeys
  after_update :update_authorizedkeys

  # some properties are mandatory and must be well-formed
  validates :name, :key, :user_id, presence: true


  # get all sshkey for admins users
  scope :admins, ->(){ joins(:user => :group).where('groups.access_level' => 50) }

  private

  # generate an uniq and well formed keyname (for os and gitlab)
  #
  def init_shortname
    self.shortname = "k#{user.id}t#{Time.zone.now.to_i.to_s.sub(/^../,'')}"
  end

  # add sshkey to openstack and gitlab
  #
  def init_sshkey
    osapi = Apiexternal::Osapi.new
    gitlabapi = Apiexternal::Gitlabapi.new

    init_shortname
    begin
      #openstack side
      osapi.add_sshkey(shortname, key)

      #gitlab side
      self.gitlab_id = gitlabapi.add_sshkey(user.gitlab_id, shortname, key)
    rescue Exceptions::NextDeployException => me
      me.log
    end
  end

  # write new version of authorizedkeys
  #
  def update_authorizedkeys
      user.update_authorizedkeys
  end

  # reset sshkey to openstack and gitlab
  #
  def reset_sshkey
    osapi = Apiexternal::Osapi.new
    gitlabapi = Apiexternal::Gitlabapi.new

    begin
      # openstack side
      osapi.delete_sshkey(shortname)
      osapi.add_sshkey(shortname, key)

      # gitlab side
      gitlabapi.delete_sshkey(user.gitlab_id, gitlab_id)
      self.gitlab_id = gitlabapi.add_sshkey(user.gitlab_id, shortname, key)
    rescue Exceptions::NextDeployException => me
      me.log
    end
  end

  # remove sshkey to openstack and gitlab
  #
  def purge_sshkey
    osapi = Apiexternal::Osapi.new
    gitlabapi = Apiexternal::Gitlabapi.new

    begin
      # openstack side
      osapi.delete_sshkey(shortname)

      # gitlab side
      gitlabapi.delete_sshkey(user.gitlab_id, gitlab_id)
    rescue Exceptions::NextDeployException => me
      me.log
    end
  end
end
