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

  has_many :supervises, dependent: :destroy
  has_many :technos, through: :supervises
  has_many :uris, -> { order(is_main: :desc) }, dependent: :destroy
  has_many :frameworks, through: :uris

  # Some scope for find vms objects by commit, by project or by name
  scope :find_by_user_commit, ->(user_id, commit){ where('user_id = :user_id AND commit_id like :commit',
                                                         user_id: user_id,
                                                         commit: "%#{commit}%") }
  scope :find_by_user_project, ->(user_id, project_id){ where(user_id: user_id, project_id: project_id) }

  attr_accessor :floating_ip, :commit, :vnc_url, :thumb

  # Some hooks before vm changes
  before_destroy :delete_vm, prepend: true

  # Init external api objects and extra attributes
  after_initialize :init_extra_attr

  # Return true if is_prod
  #
  # @return [Boolean]
  def prod?
    is_prod
  end

  # Update vm password in database
  #
  # @param password [String] password to replace
  def reset_password(password)
    self.termpassword = password
    save
  end

  # Update vm user
  #
  # @param user_id [Number] new owner of the vm
  def change_user(user_id)
    self.user = User.find(user_id)
    save

    user.update_authorizedkeys unless user.lead?
    generate_hiera
    puppet_refresh
  end

  # Update vm topic
  #
  # @param topic [String] new topic
  def set_topic(topic)
    self.topic = topic
    save
  end

  # Toggle is_ro parameter
  #
  def toggle_ro
    self.is_ro = is_ro ? false : true
    save
  end

  # Toggle is_auth parameter
  #
  def toggle_auth
    self.is_auth = is_auth ? false : true
    save
    generate_hiera
    puppet_refresh
  end

  # Toggle is_ht parameter
  #
  def toggle_ht
    self.is_ht = is_ht ? false : true
    save
    generate_hiera
    puppet_refresh
  end

  # Toggle is_ci parameter
  #
  # @param dosave [Boolean] set if object must be saved in database
  def toggle_ci(dosave = true)
    self.is_ci = is_ci ? false : true
    save if dosave
    generate_hiera
  end

  # Toggle is_backup parameter
  #
  def toggle_backup
    self.is_backup = is_backup ? false : true
    save
    generate_hiera
  end

  # Toggle is_prod parameter
  #
  def toggle_prod
    # ensure that we have still right for change a vm to prod status
    if !is_prod
      if !user.admin? &&
          user.quotaprod < user.vms.select { |v| v.is_prod }.size
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
    puppet_refresh
  end

  # Toggle is_cached parameter
  #
  def toggle_cached
    self.is_cached = is_cached ? false : true
    save
    generate_hiera
    puppet_refresh
  end

  # Toggle is_cors parameter
  #
  def toggle_cors
    self.is_cors = is_cors ? false : true
    save
    generate_hiera
    puppet_refresh
  end

  # Toggle is_offline parameter
  #
  def toggle_offline
    self.is_offline = is_offline ? false : true
    save
    generate_hiera
    puppet_refresh
  end

  # Refresh commit value
  #
  # @param commitid [String] commit to refresh
  def refresh_commit(commitid)
    tab = "#{project.id}-#{commitid}".split('-')
    commit_hash = tab.pop
    branche_id = tab.join('-')
    branche = Branche.find(branche_id)
    commits = branche.commits

    if commits && commits.any? { |commit| commit.commit_hash == commit_hash }
      self.commit_id = "#{branche.id}-#{commit_hash}"
      save
    end

    # HACK: update screenshot frequently ... ugly !
    webshot if Time.zone.now.to_i % 3 == 0
  end

  # Update status field with time build
  # And send alert mail to users
  #
  def setup_complete
    if status <= 1
        project.users.each do |u|
          if u.is_recv_vms || u.id == user.id
            VmMailer.vm_ready(u, project, user, commit, uris, htlogin, htpassword).deliver
          end
        end
    end

    self.status = (Time.zone.now - created_at).to_i
    generate_hiera
    webshot
    save
  end

  # Set uris by default with project endpoints
  #
  def init_defaulturis
    # init name if empty
    if !name || name.empty?
      self.name = vm_name
      save
    end

    project.endpoints.each do |endpoint|
      absolute = (endpoint.prefix.length > 0) ? "#{endpoint.prefix}-#{name}" : "#{name}"
      if !endpoint.aliases.nil? && !endpoint.aliases.empty?
        aliases = endpoint.aliases.split(' ').map { |aliase| "#{aliase}-#{name}" }.join(' ')
      else
        aliases = ''
      end

      Uri.new(vm: self, framework: endpoint.framework, absolute: absolute,
              path: endpoint.path, envvars: endpoint.envvars, aliases: aliases,
              port: endpoint.port, ipfilter: endpoint.ipfilter, is_sh: endpoint.is_sh,
              is_import: endpoint.is_import, is_main: endpoint.is_main, is_redir_alias: false).save
    end

    reload
  end

  # Get build time (=status if vm is running)
  # builtime is > 0 if vm is running, else is negative
  #
  # @return [Number] the build time (in seconds)
  def buildtime
    return status if status != 0

    ret = (Time.zone.now - created_at).to_i
    # more 10hours with setup status is equal to error status
    (ret > 36000) ? (1) : (-ret)
  end

  # Init vnc_url attribute
  #
  def init_vnc_url
    @vnc_url = nil

    if nova_id
      @vnc_url =
        Rails.cache.fetch("vms/#{nova_id}/vnc_url", expires_in: 180.seconds) do
          osapi = Apiexternal::Osapi.new
          # get vnc_url from openstack
          ret = osapi.get_vnctoken(nova_id)
        end
    end
  end

  # Create a new vm to openstack with current object attributes
  #
  # @raise [NextDeployException] if error occurs
  def boot
    # Raise an exception if the limit of vms is reachable
    raise Exceptions::NextDeployException.new("Vms limit is reachable") if Vm.count > Rails.application.config.limit_vm

    osapi = Apiexternal::Osapi.new

    begin
      self.name = vm_name
      self.technos = project.technos if technos.size == 0
      self.status = 0
      generate_hiera
      user_data = generate_userdata
      sshname = user.sshkeys.first ? user.sshkeys.first.shortname : ''
      self.nova_id = osapi.boot_vm(name, systemimage.glance_id, sshname, vmsize.title, user_data)
      save
      generate_authorizedkeys
    rescue Exceptions::NextDeployException => me
      self.status = 1
      save
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

  # Reboot vm
  #
  # @param type [String] type of reboot (SOFT|HARD)
  def reboot(type)
    if nova_id
      # init api object
      osapi = Apiexternal::Osapi.new
      # rewuest openstack for reboot
      osapi.reboot_vm(nova_id, type)
    end
    sleep(12)
  end

  protected

  # Return unique vm title
  #
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
  def init_extra_attr
    @floating_ip = nil
    @vnc_url = nil
    @thumb = "/thumbs/default.png"

    if nova_id
      # store floating_ip in rails cache
      @floating_ip =
        Rails.cache.fetch("vms/#{nova_id}/floating_ip", expires_in: 240.hours) do
          # init api object
          osapi = Apiexternal::Osapi.new
          # get floatingip from openstack
          ret = osapi.get_floatingip(nova_id)
          (ret) ? (ret[:ip]) : nil
        end

      # delete from cache if nil object
      Rails.cache.delete("vms/#{nova_id}/floating_ip") if @floating_ip.nil?

      # init thumb if vm installed
      if status > 1
        @thumb = "/thumbs/#{id}.png"
      end
    end

    @commit =
      Rails.cache.fetch("commits/#{commit_id}", expires_in: 240.hours) do
        Commit.find(commit_id)
      end
  end

  # Stop and delete a vm from openstack
  #
  # @raise [NextDeployException] if error occurs
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
