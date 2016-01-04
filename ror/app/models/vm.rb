# The VM Object
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class Vm < ActiveRecord::Base
  # An Heleer module contains IO functions
  include VmsHelper

  belongs_to :project
  belongs_to :vmsize

  belongs_to :user
  belongs_to :systemimage

  # Some scope for find vms objects by commit, by project or by name
  scope :find_by_user_commit, ->(user_id, commit){ where("user_id=#{user_id} AND commit_id like '%#{commit}'") }
  scope :find_by_user_project, ->(user_id, project_id){ where(user_id: user_id, project_id: project_id) }
  scope :find_by_name, ->(name){ where(name: name).first }

  attr_accessor :floating_ip, :commit

  # Some hooks before vm changes
  before_create :boot_os
  after_create :generate_host_all
  before_destroy :delete_vm

  # Init external api objects and extra attributes
  after_initialize :init_extra_attr

  # Update status field with time build
  #
  # No param
  # No return
  def setupcomplete
    self.status = (Time.zone.now - created_at).to_i
    save
  end

  # Get build time (=status if vm is running)
  # builtime is > 0 if vm is running, else is negative
  #
  # No param
  # No return
  def buildtime
    return status if status != 0

    ret = (Time.zone.now - created_at).to_i
    # more 2hours with setup status is equal to error status
    (ret > 7200) ? (1) : (-ret)
  end

  protected

  # Return unique vm title
  #
  # No param
  # @return [String] unique vm title
  def vm_name
    if !name || name.empty?
      "#{user.id}-#{project.name.gsub('.','-')}-#{Time.zone.now.to_i.to_s.sub(/^../,'')}".downcase
    else
      name
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
    raise Exceptions::NextDeployException.new("Vms limit is reachable") if Vm.all.length > Rails.application.config.limit_vm

    osapi = Apiexternal::Osapi.new

    begin
      self.name = vm_name
      generate_hiera
      generate_vcl
      user_data = generate_userdata
      sshname = user.sshkeys.first ? user.sshkeys.first.name : ''
      self.nova_id = osapi.boot_vm(name, systemimage.glance_id, sshname, vmsize.title, user_data)
      self.status = 0
    rescue Exceptions::NextDeployException => me
      me.log_e
    end
  end

  # Init extra attributes
  #
  # No param
  # No return
  def init_extra_attr
    @floating_ip = nil

    if nova_id
      # store floating_ip in rails cache
      @floating_ip =
        Rails.cache.fetch("vms/#{nova_id}/floating_ip", expires_in: 144.hours) do
          # init api object
          osapi = Apiexternal::Osapi.new
          # get floatingip from openstack
          ret = osapi.get_floatingip(nova_id)
          (ret) ? (ret[:ip]) : nil
        end
    end

    @commit =
      Rails.cache.fetch("vms/#{commit_id}/commit_object", expires_in: 144.hours) do
        Commit.find(commit_id)
      end

    #check_status
  end

  # Stop and delete a vm from openstack
  #
  # No param
  # No return
  def delete_vm
    osapi = Apiexternal::Osapi.new

    begin
      osapi.delete_vm(nova_id)
    rescue Exceptions::NextDeployException => me
      me.log
    end

    # delete hiera and vcl files
    clear_vmfiles
  end

end