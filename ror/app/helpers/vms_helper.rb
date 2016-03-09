# Stores IO functions for vm Class
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
module VmsHelper
  # Generate Hiera files with current attributes like technos array
  #
  # No param
  # @raise an exception if errors occurs during file writing
  # No return
  def generate_hiera
    vhost = project.name
    portV = 80
    portA = 8080
    portT = 8181
    docroot = "/var/www/#{vhost}/server/#{project.framework.publicfolder}"
    framework = project.framework
    rewrites = framework.rewrites
    classes = []
    templates = []
    vmtechnos = technos.sort_by(&:ordering)
    # generate ftp password
    ftppasswd = project.password

    #add base puppet class
    classes << '  - pm::base::apt'
    classes << '  - pm::base'
    classes << '  - pm::mail'
    classes << '  - pm::monitor::collect'
    classes << '  - pm::hids::agent'
    classes << '  - pm::deploy::vhost'

    vmtechnos.each do |techno|
      classes << "  - #{techno.puppetclass}"
      template = techno.hiera % {vhost: "#{vm_url}", docroot: docroot,
                                 rewrites: rewrites, portV: portV,
                                 portA: portA, portT: portT,
                                 loginV: project.login,
                                 passwordV: project.password,
                                 projectname: project.name}
      templates << template
    end

    classes << "  - #{framework.puppetclass}" if framework.puppetclass && framework.puppetclass.length > 0
    classes << "  - pm::deploy::nodejs" if technos.any? { |t| t.name.include?('nodejs') }
    classes << '  - pm::deploy::postinstall'

    begin
      open("hiera/#{name}#{Rails.application.config.os_suffix}.yaml", "w") { |f|
        f.puts "---\n\nclasses:\n"
        f.puts classes.join("\n")
        f.puts templates.join("\n")

        # tools are disabled without auth
        if is_auth
          f.puts "isauth: 1\n"
          f.puts "httpuser: '#{project.login}'\n"
          f.puts "httppasswd: '#{project.password}'\n"
        else
          f.puts "isauth: 0\n"
        end

        # varnish3 for older linux
        if systemimage.name == "Debian7" || systemimage.name == "Ubuntu1404"
          f.puts "varnish_version: 3\n"
        else
          f.puts "varnish_version: 4\n"
        end

        f.puts "name: #{name}\n"
        f.puts "commit: #{@commit.commit_hash}\n"
        f.puts "branch: #{@commit.branche.name}\n"
        f.puts "gitpath: #{Rails.application.config.gitlab_prefix}#{project.gitpath}\n"
        f.puts "email: #{user.email}\n"
        f.puts "docrootgit: /var/www/#{vhost}\n"
        f.puts "weburi: #{vm_url}\n"
        f.puts "project: #{project.name}\n"
        f.puts "nextdeployuri: #{Rails.application.config.nextdeployuri}\n"
        f.puts "system: '#{systemimage.name}'"
        f.puts "ftpuser: #{project.gitpath}\n"
        f.puts "ftppasswd: #{ftppasswd}\n"
        f.puts "framework: #{framework.name.downcase}\n"
        f.puts "ossecip: #{Rails.application.config.ndc2ip}\n"
        f.puts "influxip: #{Rails.application.config.ndc2ip}\n"
      }
    rescue => me
      raise Exceptions::NextDeployException.new("Create hiera file for #{name} failed, #{me.message}")
    end

  end

  # Generate varnish auth vcl
  #
  # No param
  # @raise an exception if errors occurs during file writing
  # No return
  def generate_vcl
    vclV = 4
    vclName = "auth.vcl_#{name}#{Rails.application.config.os_suffix}"

    # varnish3 for older linux
    if systemimage.name == "Debian7" || systemimage.name == "Ubuntu1404"
      vclV = 3
    end

    # prepare vcl file for current vm
    # todo: avoid bash cmd
    if is_auth
      basicAuth = Base64.strict_encode64(project.login + ':' + project.password)
      system("/bin/cat vcls/auth/auth.vcl.#{vclV} | /bin/sed 's,###AUTH###,,;s,%%BASICAUTH%%,#{basicAuth},' > vcls/auth/#{vclName}")
    else
      system("/bin/touch vcls/auth/#{vclName}")
    end
  end

  # Generate user-data files for cloud-init service, using after booting the vm
  #
  # No param
  # @raise an exception if errors occurs during file writing
  # No return
  def generate_userdata
    template = "cloudinit/pattern_linux.yaml"

    begin
      pattern = IO.read(template)
      pattern.gsub!('%{vmreplace}', name)
      pattern.gsub!('%{os_suffix}', Rails.application.config.os_suffix)
      pattern.gsub!('%{nextdeployip}', Rails.application.config.nextdeployip)
      pattern.gsub!('%{nextdeployhost}', Rails.application.config.nextdeployuri)
      pattern.gsub!('%{gitlabhost}', Rails.application.config.gitlab_endpoint0.sub(/https?:\/\//, ''))
    rescue => e
      raise Exceptions::NextDeployException.new("Create cloudinit file for #{name} failed: #{e}")
    end

    # encode cloudinit datas
    Base64.encode64(pattern)
  end

  # Generate Host file with delegated zone for nextdeploy virtual instances
  #
  # No param
  # @raise an exception if errors occurs during file writing
  # No return
  def generate_host_all
    # Wait that vm is well running
    sleep(15)
    vms = Vm.all

    begin
      open("/etc/hosts.nextdeploy", "w") do |f|
        vms.each do |v|
          if v.floating_ip && v.floating_ip.length > 0
            f.puts "#{v.floating_ip} #{v.vm_url} admin.#{v.vm_url} m.#{v.vm_url} nodejs.#{v.vm_url}\n"
          end
        end
      end

    rescue
      raise Exceptions::NextDeployException.new("Create hosts.nextdeploy file failed")
    end

  end

  # Check status for current vm and update it if needed
  #
  # No param
  # No return
  def check_status
    # dont check status if we are on setup process
    return if (status == 0 && created_at > (Time.zone.now - 240.minutes))

    conn_status = nil

    begin
        response =
          Rails.cache.fetch("vms/#{nova_id}/status_ok", expires_in: 30.minutes) do
            conn_status = Faraday.new(:url => "http://#{vm_url}") do |faraday|
              faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
            end

            conn_status.get do |req|
              req.url "/status_ok"
              req.options[:timeout] = 15
              req.options[:open_timeout] = 10
            end
          end
    rescue
      return
    end

    if response.status != 200
      # try a second time
      begin
        sleep(1)

        unless conn_status
          conn_status = Faraday.new(:url => "http://#{vm_url}") do |faraday|
            faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
          end
        end

        response = conn_status.get do |req|
          req.url "/status_ok"
          req.options[:timeout] = 15
          req.options[:open_timeout] = 10
        end
      rescue
        return
      end

      if response.status != 200
        Rails.logger.warn "http://#{vm_url}/status_ok"
        self.status = 1
      end
    end

    if response.status == 200 && status == 1
      self.status = Time.zone.now - created_at
      save
    end
  end

  # Clear vcls and hiera files
  #
  # No param
  # No return
  def clear_vmfiles
    Rails.logger.warn "rm -f vcls/auth/auth.vcl_#{name}#{Rails.application.config.os_suffix}"
    Rails.logger.warn "rm -f hiera/#{name}#{Rails.application.config.os_suffix}.yaml"
    system("rm -f vcls/auth/auth.vcl_#{name}#{Rails.application.config.os_suffix}")
    system("rm -f hiera/#{name}#{Rails.application.config.os_suffix}.yaml")
  end

end
