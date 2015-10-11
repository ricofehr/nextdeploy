# Stores IO functions for vm Class
#
# @author Eric Fehr (eric.fehr@publicis-modem.fr, @github: ricofehr)
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
    rewrites = project.framework.rewrites
    classes = Array.new
    templates = Array.new
    technos = project.technos
    technos = technos.sort_by {|t| t.ordering}

    #add base puppet class
    classes << '  - pm::base::apt'
    classes << '  - pm::base'
    classes << '  - pm::deploy::vhost'
    technos.each { |techno|
      classes << "  - #{techno.puppetclass}"
      template = techno.hiera % {vhost: "#{vm_url}", docroot: docroot,
                                 rewrites: rewrites, portV: portV,
                                 portA: portA, portT: portT,
                                 loginV: project.login,
                                 passwordV: project.password}
      templates << template
    }
    classes << "  - #{project.framework.puppetclass}" if project.framework.puppetclass && project.framework.puppetclass.length > 0
    classes << "  - pm::deploy::nodejs" if project.technos.any? { |t| t.name == 'nodejs' }
    classes << '  - pm::deploy::postinstall'

    begin
      open("hiera/#{self.name}#{Rails.application.config.os_suffix}.yaml", "w") { |f|
        f.puts "---\n\nclasses:\n"
        f.puts classes.join("\n")
        f.puts templates.join("\n")
        # varnish3 for old linux, v4 for newer
        if systemimage.name == "Debian7" || systemimage.name == "Ubuntu1404"
          f.puts "varnish_version: 3\n"
        else
          f.puts "varnish_version: 4\n"
        end

        if project.login && project.login.length > 0
          f.puts 'varnish_auth: ' + Base64.strict_encode64(project.login + ':' + project.password)
          f.puts "is_auth: 'yes'"
        else
          f.puts "is_auth: 'no'"
        end

        f.puts "commit: #{commit.commit_hash}\n"
        f.puts "branch: #{commit.branche.name}\n"
        f.puts "gitpath: #{Rails.application.config.gitlab_prefix}#{project.gitpath}\n"
        f.puts "email: #{user.email}\n"
        f.puts "docrootgit: /var/www/#{vhost}\n"
        f.puts "weburi: #{vm_url}\n"
        f.puts "project: #{project.name}\n"
        f.puts "mvmcuri: #{Rails.application.config.mvmcuri}\n"
      }
    rescue
      raise Exceptions::MvmcException.new("Create hiera file for #{name} failed")
    end

  end

  # Generate user-data files for cloud-init service, using after booting the vm
  #
  # No param
  # @raise an exception if errors occurs during file writing
  # No return
  def generate_userdata
    #vhost = project.prefix_dns_s.first.URI
    template = "cloudinit/pattern_linux.yaml"
    vm_replace = self.name

    begin
      pattern = IO.read(template)
      pattern.gsub!('%{vmreplace}', vm_replace)
      pattern.gsub!('%{os_suffix}', Rails.application.config.os_suffix)
      pattern.gsub!('%{mvmcip}', Rails.application.config.mvmcip)
      pattern.gsub!('%{mvmchost}', Rails.application.config.mvmcuri)
      # ft = File.open(template, "rb")
      # pattern = ft.read
      # ft.close()
    rescue Exception => e
      raise Exceptions::MvmcException.new("Create cloudinit file for #{name} failed: #{e}")
    end

    # encode cloudinit datas
    Base64.encode64(pattern)
  end

  # Generate Host file with delegated zone for mvmc virtual instances
  #
  # No param
  # @raise an exception if errors occurs during file writing
  # No return
  def generate_host_all
    # Wait that vm is well running
    sleep(15)
    vms = Vm.all

    begin
      open("/etc/hosts.mvmc", "w") { |f|
        vms.each { |v|
          f.puts "#{v.floating_ip} #{v.vm_url} admin.#{v.vm_url} m.#{v.vm_url} nodejs.#{v.vm_url}\n" if v.floating_ip && v.floating_ip.length > 0
        }
      }

    rescue
      raise Exceptions::MvmcException.new("Create hosts.mvmc file failed")
    end

  end

  # Check status for current vm and update it if needed
  #
  # No param
  # No return
  def check_status
    conn_status = Faraday.new(:url => "http://#{vm_url}") do |faraday|
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end

    begin
      response = conn_status.get do |req|
        req.url "/status_ok"
      end
    rescue
      self.status = 2 if self.status == 1 || (self.updated_at && self.updated_at < (Time.now - 120.minutes))
      return
    end

    if response.status == 200
      self.status = 1
    else
      self.status = 2 if self.status == 1 || (self.updated_at && self.updated_at < (Time.now - 120.minutes))
    end
  end

end
