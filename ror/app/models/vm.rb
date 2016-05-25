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

  has_many :vm_technos, dependent: :destroy
  has_many :technos, through: :vm_technos
  has_many :uris, dependent: :destroy
  has_many :frameworks, through: :uris

  # Some scope for find vms objects by commit, by project or by name
  scope :find_by_user_commit, ->(user_id, commit){ where("user_id=#{user_id} AND commit_id like '%#{commit}'") }
  scope :find_by_user_project, ->(user_id, project_id){ where(user_id: user_id, project_id: project_id) }

  attr_accessor :floating_ip, :commit, :vnc_url

  # Some hooks before vm changes
  #before_create :boot_os
  #after_create :generate_host_all
  before_destroy :delete_vm

  # Init external api objects and extra attributes
  after_initialize :init_extra_attr

  # Update vm password in database
  #
  # No param
  # No return
  def reset_password(password)
    self.termpassword = password
    save
  end

  # Update vm user
  #
  # No param
  # No return
  def change_user(user_id)
    self.user = User.find(user_id)
    save

    generate_hiera
    puppetrefresh
  end

  # Toggle is_auth parameter
  #
  # No param
  # No return
  def toggleauth
    self.is_auth = is_auth ? false : true
    save
    generate_hiera
    puppetrefresh
  end

  # Toggle is_ht parameter
  #
  # No param
  # No return
  def toggleht
    self.is_ht = is_ht ? false : true
    save
    generate_hiera
    puppetrefresh
  end

  # Toggle is_backup parameter
  #
  # No param
  # No return
  def togglebackup
    self.is_backup = is_backup ? false : true
    save
    generate_hiera
  end

  # Toggle is_prod parameter
  #
  # No param
  # No return
  def toggleprod
    # ensure that we have still right for change a vm to prod status
    if !is_prod
      if !user.admin? &&
          user.quotaprod > user.vms.select { |v| v.is_prod }.size
        return
      end
    end

    self.is_prod = is_prod ? false : true
    save

    if !is_prod
      Uri.destroy_all(id: uris.flat_map(&:id)) if uris && uris.size > 0
      reload

      init_defaulturis
      generate_host_all
    end

    generate_hiera
    puppetrefresh
  end

  # Toggle is_cached parameter
  #
  # No param
  # No return
  def togglecached
    self.is_cached = is_cached ? false : true
    save
    generate_hiera
    puppetrefresh
  end

  # Refresh commit value
  #
  # No param
  # No return
  def refreshcommit(commitid)
    tab = "#{project.id}-#{commitid}".split('-')
    commit_hash = tab.pop
    branche_id = tab.join('-')
    branche = Branche.find(branche_id)
    commits = branche.commits

    if commits && commits.any? { |commit| commit.commit_hash == commit_hash }
      self.commit_id = "#{branche.id}-#{commit_hash}"
      save
    end
  end

  # Update status field with time build
  #
  # No param
  # No return
  def setupcomplete
    self.status = (Time.zone.now - created_at).to_i
    save
  end

  # Set uris by default with project endpoints
  #
  # No param
  # No return
  def init_defaulturis
    project.endpoints.each do |endpoint|
      absolute = (endpoint.prefix.length > 0) ? "#{endpoint.prefix}.#{name}" : "#{name}"
      if !endpoint.aliases.nil? && !endpoint.aliases.empty?
        aliases = endpoint.aliases.split(' ').map { |aliase| "#{aliase}.#{name}" }.join(' ')
      else
        aliases = ''
      end
      Uri.new(vm: self, framework: endpoint.framework, absolute: absolute, path: endpoint.path, envvars: endpoint.envvars, aliases: aliases, port: endpoint.port, ipfilter: endpoint.ipfilter).save
    end

    reload
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

  # Init vnc_url attribute
  #
  # No param
  # No return
  def init_vnc_url
    @vnc_url = nil

    if nova_id
      @vnc_url =
        Rails.cache.fetch("vms/#{nova_id}/vnc_url", expires_in: 120.seconds) do
          # init api object
          osapi = Apiexternal::Osapi.new
          # get vnc_url from openstack
          ret = osapi.get_vnctoken(nova_id)
        end
    end
  end

  # Create a new vm to openstack with current object attributes
  #
  # No param
  # No return
  def boot
    # Raise an exception if the limit of vms is reachable
    raise Exceptions::NextDeployException.new("Vms limit is reachable") if Vm.all.length > Rails.application.config.limit_vm

    osapi = Apiexternal::Osapi.new

    begin
      self.name = vm_name
      self.technos = project.technos if technos.size == 0
      generate_hiera
      user_data = generate_userdata
      sshname = user.sshkeys.first ? user.sshkeys.first.shortname : ''
      self.nova_id = osapi.boot_vm(name, systemimage.glance_id, sshname, vmsize.title, user_data)
      self.status = 0
      save
    rescue Exceptions::NextDeployException => me
      me.log_e
    end

    # Wait that vm is well running
    sleep(15)
    init_extra_attr
    # if foatingip is not yet setted by openstack, sleep 15s more
    if @floating_ip.nil?
      sleep(15)
      init_extra_attr
    end

    generate_host_all
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

  private

  # Init extra attributes
  #
  # No param
  # No return
  def init_extra_attr
    @floating_ip = nil
    @vnc_url = nil

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

        # delete from cache if nil object
        Rails.cache.delete("vms/#{nova_id}/floating_ip") if @floating_ip.nil?
    end

    @commit =
      Rails.cache.fetch("commits/#{commit_id}", expires_in: 144.hours) do
        Commit.find(commit_id)
      end
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
    generate_host_all
  end

end
