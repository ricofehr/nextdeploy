# The VM Object
#
# @author Eric Fehr (eric.fehr@publicis-modem.fr, github: ricofehr)
class Vm < ActiveRecord::Base
  # An Heleer module contains IO functions
  include VmsHelper

  belongs_to :project
  belongs_to :vmsize

  belongs_to :user
  belongs_to :systemimage

  # Some scope for find vms objects by commit or by project
  scope :find_by_user_commit, ->(user_id, commit){ where("user_id=#{user_id} AND commit_id like '%#{commit}'") }
  scope :find_by_user_project, ->(user_id, project_id){ where(user_id: user_id, project_id: project_id) }

  attr_accessor :floating_ip, :commit

  # Some hooks before vm changes
  before_create :boot_os
  after_create :generate_host_all
  before_destroy :delete_vm

  # Init external api objects and extra attributes
  after_initialize :init_osapi, :init_extra_attr

  @osapi = nil

  protected

  # Return unique vm title
  #
  # No param
  # @return [String] unique vm title
  def vm_name
    user = self.user
    project = self.project
    if !self.name || self.name.empty?
      "#{user.id}-#{project.name.gsub('.','-')}-#{Time.now.to_i.to_s.gsub(/^../,'')}".downcase
    else
      self.name
    end
  end

  # Return main URL vm
  #
  # No param
  # @return [String] url targetting the vm
  def vm_url
    "#{vm_name}#{Rails.application.config.os_suffix}"
  end

  private

  # Create a new vm to openstack with current object attributes
  #
  # No param
  # No return
  def boot_os
    # Raise an exception if the limit of vms is reachable
    raise Exceptions::MvmcException.new("Vms limit is reachable") if Vm.all.length > Rails.application.config.limit_vm

    begin
      self.name = vm_name
      generate_hiera
      user_data = generate_userdata
      sshname = user.sshkeys.first ? user.sshkeys.first.name : ''
      self.nova_id = @osapi.boot_vm(self.name, systemimage.glance_id, sshname, self.vmsize.title, user_data)
      self.status = 0
    rescue Exceptions::MvmcException => me
      me.log
    end
  end

  # Init openstack api object
  #
  # No param
  # No return
  def init_osapi
    @osapi = Apiexternal::Osapi.new
  end

  # Init extra attributes
  #
  # No param
  # No return
  def init_extra_attr
    @floating_ip = nil

    if self.nova_id
      ret = @osapi.get_floatingip(self.nova_id)
      @floating_ip = ret[:ip] if ret
    end

    @commit = Commit.find(self.commit_id)
    check_status
  end

  # Stop and delete a vm from openstack
  #
  # No param
  # No return
  def delete_vm
    begin
      @osapi.delete_vm(self.nova_id)
    rescue Exceptions::MvmcException => me
      me.log
    end
    system("rm -f hiera/#{self.name}#{Rails.application.config.os_suffix}.yaml")
  end

end