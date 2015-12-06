# Stores properties about ssh key and execute background command for gitlab / cloud.
#
# @author Eric Fehr (eric.fehr@publicis-modem.fr, github: ricofehr)
class Sshkey < ActiveRecord::Base
  belongs_to :user

  # some hooks befor key changes
  before_create :init_gitlabapi, :init_osapi, :init_sshkey
  before_destroy :init_gitlabapi, :init_osapi, :purge_sshkey
  before_update :init_gitlabapi, :init_osapi, :reset_sshkey

  # some hooks after key changes
  after_create :update_authorizedkeys
  after_destroy :update_authorizedkeys
  after_update :update_authorizedkeys

  # some properties are mandatory and must be well-formed
  validates :name, :key, :user_id, presence: true


  #get all sshkey for admins users
  scope :admins, ->(){ joins(:user => :group).where('groups.access_level' => 50) }

  # Api objecs init to nil
  @osapi = nil
  @gitlabapi = nil

  private

  # Init openstack api object
  #
  # No param
  # No return
  def init_osapi
    @osapi = Apiexternal::Osapi.new
  end

  # Init gitlab api object
  #
  # No param
  # No return
  def init_gitlabapi
    @gitlabapi = Apiexternal::Gitlabapi.new
  end

  # add sshkey to openstack and gitlab
  #
  # No param
  # No return
  def init_sshkey
    begin
      #openstack side
      @osapi.add_sshkey(self.name, self.key)

      #gitlab side
      self.gitlab_id = @gitlabapi.add_sshkey(user.gitlab_id, self.name, self.key)
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
      self.user.generate_authorizedkeys
      self.user.generate_all_authorizedkeys if self.user.admin?
      self.user.upload_authorizedkeys
  end


  # reset sshkey to openstack and gitlab
  #
  # No param
  # No return
  def reset_sshkey
    begin
      #openstack side
      @osapi.delete_sshkey(self.name)
      @osapi.add_sshkey(self.name, self.key)

      #gitlab side
      @gitlabapi.delete_sshkey(user.gitlab_id, self.gitlab_id)
      self.gitlab_id = @gitlabapi.add_sshkey(user.gitlab_id, self.name, self.key)
    rescue Exceptions::NextDeployException => me
      me.log
    end
  end

  # remove sshkey to openstack and gitlab
  #
  # No param
  # No return
  def purge_sshkey
    begin
      #openstack side
      @osapi.delete_sshkey(self.name)

      #gitlab side
      @gitlabapi.delete_sshkey(user.gitlab_id, self.gitlab_id)
    rescue Exceptions::NextDeployException => me
      me.log
    end
  end
end
