# Stores IO functions for vm Class
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
module VmsHelper

  # Generate authorized ssh key
  #
  # No param
  # No return
  def generate_authorizedkeys

    begin
      open("/tmp/vm#{id}.lock", File::RDWR|File::CREAT) do |f|
        f.flock(File::LOCK_EX)

        # todo: avoid bash cmd
        system('mkdir -p sshkeys/vms')
        system("rm -f sshkeys/vms/#{name}.authorized_keys")
        system("touch sshkeys/vms/#{name}.authorized_keys")
        # add server nextdeploy public key to authorized_keys
        system("cat ~/.ssh/id_rsa.pub > sshkeys/vms/#{name}.authorized_keys")
        Sshkey.admins.each { |k| system("echo #{k.key} >> sshkeys/vms/#{name}.authorized_keys") }
        user.sshkeys.each { |k| system("echo #{k.key} >> sshkeys/vms/#{name}.authorized_keys") }
        project.users.select { |u| u.lead? }.each do |u|
          u.sshkeys.each { |k| system("echo #{k.key} >> sshkeys/vms/#{name}.authorized_keys") }
        end
        system("chmod 644 sshkeys/vms/#{name}.authorized_keys")
      end

    rescue
      raise Exceptions::NextDeployException.new("Lock on authkeys for #{name} failed")
    end
  end

  # Generate Hiera files with current attributes like technos array
  #
  # No param
  # @raise an exception if errors occurs during file writing
  # No return
  def generate_hiera
    vhost = project.name
    classes = []
    templates = []
    vmtechnos = technos.sort_by(&:ordering)
    # generate ftp password
    ftppasswd = project.password
    rewrites = ""
    basicAuth = Base64.strict_encode64(htlogin + ':' + htpassword)

    #add base puppet class
    classes << '  - pm::base::apt'
    classes << '  - pm::base'
    classes << '  - pm::mail'
    classes << '  - pm::monitor::collect'
    classes << '  - pm::hids::agent'
    classes << '  - pm::deploy::vhost'

    vmtechnos.each do |techno|
      classes << "  - #{techno.puppetclass}"
      template = techno.hiera
      templates << template
    end

    classes << '  - pm::deploy::postinstall'

    begin
      open("hiera/#{name}#{Rails.application.config.os_suffix}.yaml", File::RDWR|File::CREAT) do |f|
        f.flock(File::LOCK_EX)
        f.rewind

        f.puts "---\n\nclasses:\n"
        f.puts classes.join("\n")
        f.puts templates.join("\n")

        # tools are disabled without auth
        if is_auth
          f.puts "isauth: 1\n"
          f.puts "httpuser: '#{htlogin}'\n"
          f.puts "httppasswd: '#{htpassword}'\n"
        else
          f.puts "isauth: 0\n"
        end

        if is_prod
          f.puts "isprod: 1\n"
          f.puts "webenv: 'prod'\n"
        else
          f.puts "isprod: 0\n"
          f.puts "webenv: 'dev'\n"
        end

        if is_cached
          f.puts "iscached: 1\n"
        else
          f.puts "iscached: 0\n"
        end

        if is_ci
          f.puts "isci: 1\n"
        else
          f.puts "isci: 0\n"
        end

        if is_backup
          f.puts "isbackup: 1\n"
        else
          f.puts "isbackup: 0\n"
        end

        if is_ht
          f.puts "override: 'All'"
        else
          f.puts "override: 'None'"
        end

        f.puts "uris:\n"
        uris.each do |uri|
          rewrites = uri.framework.rewrites
          # change some rewrites for prod env
          if is_prod
            rewrites.gsub!("app_dev", "app")
          end
          f.puts "  #{uri.absolute}:\n"
          f.puts "    path: #{uri.path}\n"

          if !uri.aliases.nil? && !uri.aliases.empty?
            f.puts "    aliases:\n"
            uri.aliases.split(' ').each { |aliase| f.puts "      - #{aliase}\n" }
          end

          if !uri.envvars.nil? && !uri.envvars.empty?
            f.puts "    envvars:\n"
            f.puts "      - HOME=/home/modem\n"
            uri.envvars.split(' ').each do |envvar|
              uris.each do |uri2|
                eppath = uri2.path.upcase
                envvar.gsub!("%{URI_#{eppath}}", uri2.absolute)
                envvar.gsub!("%{PORT_#{eppath}}", "#{uri2.port}")
              end
              f.puts "      - #{envvar}\n"
            end
          end

          f.puts "    framework: #{uri.framework.name.downcase}\n"
          f.puts "    publicfolder: '#{uri.framework.publicfolder}'\n"
          f.puts "    rewrites: \"#{rewrites}\"\n"
          f.puts "    customvhost: \"#{uri.customvhost ? uri.customvhost.gsub("\n","\\n") : ''}\"\n"
        end

        f.puts "etchosts: '#{uris.flat_map(&:absolute).join(' ').strip} #{uris.flat_map(&:aliases).join(' ').strip}'\n"

        f.puts "pm::varnish::backends:\n"
        uris.each do |uri|
          f.puts "  - absolute: #{uri.absolute}\n"
          f.puts "    path: #{uri.path}\n"
          f.puts "    port: #{uri.port}\n"
          if !uri.aliases.nil? && !uri.aliases.empty?
            f.puts "    aliases:\n"
            uri.aliases.split(' ').each { |aliase| f.puts "      - #{aliase}\n" }
          end
          f.puts "    is_redir_alias: #{uri.is_redir_alias}\n"
          f.puts "    ipfilter: '#{uri.ipfilter.gsub('.0/24', '').gsub('.', '\.')}'\n"
        end

        if is_prod
          f.puts "pm::varnish::staticttl: 24h\n"
        else
          f.puts "pm::varnish::staticttl: 30m\n"
        end

        f.puts "pm::varnish::isprod: #{is_prod}\n"
        f.puts "pm::varnish::isauth: #{is_auth}\n"
        f.puts "pm::varnish::iscached: #{is_cached}\n"
        f.puts "pm::varnish::iscors: #{is_cors}\n"
        f.puts "pm::varnish::basicauth: #{basicAuth}\n"

        # varnish3 for older linux
        if systemimage.name == "Debian7" || systemimage.name == "Ubuntu1404"
          f.puts "pm::varnish::version: 3\n"
        else
          f.puts "pm::varnish::version: 4\n"
        end

        f.puts "name: #{name}\n"
        f.puts "toolsuri: pmtools.#{name}#{Rails.application.config.os_suffix}\n"
        f.puts "commit: #{@commit.commit_hash}\n"
        f.puts "branch: #{@commit.branche.name}\n"
        f.puts "gitpath: #{Rails.application.config.gitlab_prefix}#{project.gitpath}\n"
        f.puts "email: #{user.email}\n"
        f.puts "layout: #{user.layout}\n"
        f.puts "docrootgit: /var/www/#{vhost}\n"
        f.puts "project: #{project.name}\n"
        f.puts "nextdeployuri: #{Rails.application.config.nextdeployuri}\n"
        f.puts "system: '#{systemimage.name}'"
        f.puts "ftpuser: #{project.gitpath}\n"
        f.puts "ftppasswd: #{ftppasswd}\n"
        f.puts "ossecip: #{Rails.application.config.ndc2ip}\n"
        f.puts "influxip: #{Rails.application.config.ndc2ip}\n"

        f.flush
        f.truncate(f.pos)
      end
    rescue => me
      raise Exceptions::NextDeployException.new("Create hiera file for #{name} failed, #{me.message}")
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
    vms = Vm.all

    begin
      open("/etc/hosts.nextdeploy", File::RDWR|File::CREAT) do |f|
        f.flock(File::LOCK_EX)
        f.rewind

        vms.each do |v|
          absolutes = v.uris.flat_map(&:absolute)
          aliases = v.uris.flat_map(&:aliases)
          if v.floating_ip && v.floating_ip.length > 0
            f.puts "#{v.floating_ip} #{absolutes.join(' ')} #{aliases.join(' ')} pmtools.#{v.name}#{Rails.application.config.os_suffix}\n"
          end
        end

        f.flush
        f.truncate(f.pos)
      end

    rescue
      raise Exceptions::NextDeployException.new("Create hosts.nextdeploy file failed")
    end

  end

  # Clear vcls and hiera files
  #
  # No param
  # No return
  def clear_vmfiles
    Rails.logger.warn "rm -f hiera/#{name}#{Rails.application.config.os_suffix}.yaml"
    system("rm -f hiera/#{name}#{Rails.application.config.os_suffix}.yaml")
    system("rm -f thumbs/#{id}.png")
    system("rm -f /tmp/vm#{id}.lock")
  end

  # Execute gitpull cmd into vms
  #
  # No param
  # @return message for execution and codestatus for request
  def gitpull
    docroot = "/var/www/#{project.name}/"
    bashret = ''

    Rails.logger.warn "Gitpull command for vm #{vm_name}"

    # take a lock for vm action
    begin
      open("/tmp/vm#{id}.lock", File::RDWR|File::CREAT) do |f|
        f.flock(File::LOCK_EX)
        bashret = `ssh modem@#{floating_ip} 'cd #{docroot};git reset --hard HEAD >/dev/null;git pull --rebase 2>&1;git cat-file -p HEAD'`
      end

    rescue
      raise Exceptions::NextDeployException.new("Lock on gitpull command for #{name} failed")
    end

    # Return bash output
    { message: bashret, status: 200 }
  end

  # Check if ci is currently executed
  #
  # No param
  # @return message for execution and codestatus for request
  def checkci
    bashret = ''

    Rails.logger.warn "Checkci for vm #{vm_name}"
    bashret = `ssh modem@#{floating_ip} 'test -f /tmp/commithash1 && echo NOK'`

    return true if bashret.match(/NOK/)
    return false
  end

  # Clear ci lock
  #
  # No param
  # @return nothing
  def clearci
    Rails.logger.warn "Remove ci lock for vm #{vm_name}"
    `ssh modem@#{floating_ip} 'rm -f /tmp/commithash1 /tmp/commithash2'`
  end

  # Display postinstall script before approvement
  #
  # No param
  # @return message for execution and codestatus for request
  def postinstall_display
    docroot = "/var/www/#{project.name}/"
    bashret = ''

    Rails.logger.warn "Postinstall display command for vm #{vm_name}"
    bashret = `ssh modem@#{floating_ip} 'cd #{docroot};cat scripts/postinstall.sh'`

    # Return bash output
    { message: bashret, status: 200 }
  end

  # Display postinstall script before approvement
  #
  # No param
  # @return message for execution and codestatus for request
  def postinstall
    docroot = "/var/www/#{project.name}/"
    bashret = ''

    Rails.logger.warn "Postinstall command for vm #{vm_name}"
    # take a lock for vm action
    begin
      open("/tmp/vm#{id}.lock", File::RDWR|File::CREAT) do |f|
        f.flock(File::LOCK_EX)
        bashret = `ssh modem@#{floating_ip} 'cd #{docroot};./scripts/./postinstall.sh'`
      end

    rescue
      raise Exceptions::NextDeployException.new("Lock on gitpull command for #{name} failed")
    end

    # Return bash output
    { message: bashret, status: 200 }
  end

  # Execute puppet cmd into vms
  #
  # No param
  # No return
  def puppetrefresh
    Rails.logger.warn "ssh modem@#{floating_ip} 'sudo /usr/bin/puppet agent -t;(($? == 1)) && sleep 30 && sudo /usr/bin/puppet agent -t'"

    # take a lock for vm action
    begin
      open("/tmp/vm#{id}.lock", File::RDWR|File::CREAT) do |f|
        f.flock(File::LOCK_EX)
        system("ssh modem@#{floating_ip} 'sudo /usr/bin/puppet agent -t;(($? == 1)) && sleep 30 && sudo /usr/bin/puppet agent -t'")
      end

    rescue
      raise Exceptions::NextDeployException.new("Lock on puppetrefresh command for #{name} failed")
    end

  end

  # Return some vm logs
  #
  # No param
  # @return message for execution and codestatus for request
  def logs
    apache_logs = uris.flat_map(&:absolute).map { |absolute| "/var/log/apache2/#{absolute}_access.log /var/log/apache2/#{absolute}_error.log" }.join(' ')

    Rails.logger.warn "ssh modem@#{floating_ip} 'sudo tail -n 60 #{apache_logs} /var/log/mysql.err /var/log/mail.log'"
    bashret = `ssh modem@#{floating_ip} "sudo tail -n 60 #{apache_logs} /var/log/mysql.err /var/log/mail.log"`

    # Return bash output
    { message: bashret, status: 200 }
  end

  def webshot
    uri = uris.first

    # Wait vm is installed
    return if status < 2

    # Delete thumb every 5 hours
    system("/usr/bin/find thumbs/. -type f -name #{id}.png -cmin +300 -exec /bin/rm -f {} \\;")
    return if File.exist?("thumbs/#{id}.png")

    #take a lock for once shot at time
    begin
      open("/tmp/webshot.lock", File::RDWR|File::CREAT) do |f|
        f.flock(File::LOCK_EX)
        suppress(Exception) do
          # Setup Capybara
          ws = Webshot::Screenshot.instance
          # Customize thumbnail
          ws.capture "http://#{htlogin}:#{htpassword}@#{uri.absolute}/", "thumbs/#{id}.png", width: 360, height: 240, quality: 85
        end
      end
    rescue => e
      raise Exceptions::NextDeployException.new("Lock on webshot command for #{name} failed, #{e.message}")
    end
  end

end
