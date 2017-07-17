# Stores IO functions for vm Class
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
module VmsHelper

  # Generate authorized ssh key
  #
  # @raise [NextDeployException] if errors occurs during lock handling
  def generate_authorizedkeys

    system('mkdir -p sshkeys/vms')

    # Read nextdeploy server public key
    ndk = ''
    begin
      ndk = open("/home/modem/.ssh/id_rsa.pub", "rb") { |io| io.read }
    rescue
      raise Exceptions::NextDeployException.new("Read nextdeploy server key failed")
    end

    begin
      open("sshkeys/vms/#{name}.authorized_keys", File::RDWR|File::CREAT, 0644) do |f|
        f.flock(File::LOCK_EX)
        f.rewind

        f.puts ndk
        Sshkey.admins.each { |k| f.puts k.key }

        project.users.select { |u| u.lead? }.each do |u|
          unless u.admin?
            u.sshkeys.each { |k| f.puts k.key }
          end
        end

        unless user.lead?
          user.sshkeys.each { |k| f.puts k.key }
        end

        # if vm is already running, transfer to it
        if status > 1
          bash_cmd = "rsync -avzPe \"ssh -o StrictHostKeyChecking=no " +
                     "-o UserKnownHostsFile=/dev/null\" sshkeys/vms/#{name.shellescape}.authorized_keys " +
                     "modem@#{floating_ip.shellescape}:~/.ssh/authorized_keys"

          Rails.logger.warn(bash_cmd)
          system(bash_cmd)
        end
      end

    rescue
      raise Exceptions::NextDeployException.new("Lock on authkeys for #{name} failed")
    end
  end

  # Generate Hiera file for current vm
  # TODO Split and reduce this 200 lines function
  #
  # @raise [NextDeployException] if errors occurs during file writing
  def generate_hiera
    # local vars
    vhost = project.name
    classes = []
    templates = []
    vmtechnos = technos.sort_by(&:ordering)
    ftppasswd = project.password
    rewrites = ""
    basic_auth = Base64.strict_encode64(htlogin + ':' + htpassword)
    os_suffix = Rails.application.config.os_suffix
    gitlab_prefix = Rails.application.config.gitlab_prefix
    nextdeployuri = Rails.application.config.nextdeployuri
    ndc2ip = Rails.application.config.ndc2ip

    # add base puppet class
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

    if is_jenkins
      if status <= 1
        classes << '  - pm::ci::cijenkins'
        classes << '  - pm::ci::cisonar'
      end

      classes << '  - pm::ci::cidoc'
      classes << '  - pm::ci::ciw3af'
    end

    classes << '  - pm::deploy::postinstall'

    begin
      open("hiera/#{name}#{os_suffix}.yaml", File::RDWR|File::CREAT) do |f|
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

        if prod?
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
          if prod?
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
          cnt_instances = 1
          if uri.envvars.match('CLUSTERING=')
            cnt_instances = uri.envvars.gsub(/^.*CLUSTERING=/,'').gsub(/ .*$/,'').to_i
          end
          f.puts "    clustering: #{cnt_instances}\n"
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
          f.puts "    is_ssl: #{uri.is_ssl}\n"
          f.puts "    ipfilter: '#{uri.ipfilter.gsub('.0/24', '').gsub('.', '\.')}'\n"
        end

        if prod?
          f.puts "pm::varnish::staticttl: 24h\n"
        else
          f.puts "pm::varnish::staticttl: 30m\n"
        end

        f.puts "pm::varnish::isprod: #{is_prod}\n"
        f.puts "pm::varnish::isauth: #{is_auth}\n"
        f.puts "pm::varnish::iscached: #{is_cached}\n"
        f.puts "pm::varnish::iscors: #{is_cors}\n"
        f.puts "pm::varnish::isoffline: #{is_offline}\n"
        f.puts "pm::varnish::basicauth: #{basic_auth}\n"

        # varnish3 for older linux
        if systemimage.name == "Debian7" || systemimage.name == "Ubuntu1404"
          f.puts "pm::varnish::version: 3\n"
        else
          f.puts "pm::varnish::version: 4\n"
        end

        f.puts "name: #{name}\n"
        f.puts "toolsuri: pmtools-#{name}#{os_suffix}\n"

        if is_jenkins
          f.puts "docuri: pmdoc-#{name}#{os_suffix}\n"
          f.puts "commit: HEAD\n"
        else
          f.puts "commit: #{@commit.commit_hash}\n"
        end

        f.puts "branch: #{@commit.branche.name}\n"
        f.puts "gitpath: #{gitlab_prefix}#{project.gitpath}\n"
        f.puts "email: #{user.email}\n"
        f.puts "layout: #{user.layout}\n"
        f.puts "docrootgit: /var/www/#{vhost}\n"
        f.puts "project: #{project.name}\n"
        f.puts "nextdeployuri: #{nextdeployuri}\n"
        f.puts "system: '#{systemimage.name}'"
        f.puts "ftpuser: #{project.gitpath}\n"
        f.puts "ftppasswd: #{ftppasswd}\n"
        f.puts "ossecip: #{ndc2ip}\n"
        f.puts "influxip: #{ndc2ip}\n"

        f.flush
        f.truncate(f.pos)
      end
    rescue => me
      raise Exceptions::NextDeployException.new("Create hiera file for #{name} failed, #{me.message}")
    end

  end

  # Generate user-data files for cloud-init service, using after booting the vm
  #
  # @raise [NextDeployException] if errors occurs during file writing
  # @return [String] user_data base64 encoded
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
  # @raise [NextDeployException] if errors occurs during file writing
  def generate_host_all

    begin
      open("/etc/hosts.nextdeploy", File::RDWR|File::CREAT) do |f|
        f.flock(File::LOCK_EX)
        f.rewind

        Vm.find_each do |v|
          uri_suffix = "#{v.name}#{Rails.application.config.os_suffix}"
          absolutes = v.uris.flat_map(&:absolute)
          aliases = v.uris.flat_map(&:aliases)
          hosts_line = "#{v.floating_ip} #{absolutes.join(' ')} " +
                       "#{aliases.join(' ')} pmtools-#{uri_suffix}"

          if v.floating_ip && v.floating_ip.length > 0
            if v.is_jenkins
              f.puts "#{hosts_line} pmdoc-#{uri_suffix} sonar-#{uri_suffix} jenkins-#{uri_suffix}\n"
            else
              f.puts "#{hosts_line}\n"
            end
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
  def clear_vmfiles
    Rails.logger.warn("rm -f hiera/#{name}#{Rails.application.config.os_suffix}.yaml")
    system("rm -f hiera/#{name.shellescape}#{Rails.application.config.os_suffix}.yaml")
    system("rm -f sshkeys/vms/#{name.shellescape}.authorized_keys")
    system("rm -f thumbs/#{id}.png")
    # keep temporary a requested thumb file for avoid 404 on cached browser items
    system("cd thumbs && ln -sf default.png #{id}.png")
    system("rm -f /tmp/vm#{id}.lock")
  end

  # Generate default webshot
  #
  def generate_defaultwebshot
    system("cp -f thumbs/default.png thumbs/#{id}.png")
  end

  # Execute gitpull cmd into vms
  #
  # @raise [NextDeployException] if errors occurs during lock handling
  # @return [Hash{Symbol => String, Number}] message from cmd and status code
  def gitpull
    docroot = "/var/www/#{project.name.shellescape}/"
    bashret = ''

    # take a lock for vm action
    begin
      open("/tmp/vm#{id}.lock", File::RDWR|File::CREAT) do |f|
        f.flock(File::LOCK_EX)

        bash_cmd = "cd #{docroot};git reset --hard HEAD >/dev/null;git pull --rebase 2>&1;git cat-file -p HEAD"
        Rails.logger.warn("Gitpull command for vm #{vm_name}")
        bashret = `ssh modem@#{floating_ip.shellescape} '#{bash_cmd}'`
      end

    rescue
      raise Exceptions::NextDeployException.new("Lock on gitpull command for #{name} failed")
    end

    # Return bash output
    { message: bashret, status: 200 }
  end

  # Check if ci is currently executed
  #
  # @return [Boolean] if executing
  def checkci
    bashret = ''

    Rails.logger.warn("Checkci for vm #{vm_name}")
    bashret = `ssh modem@#{floating_ip.shellescape} 'test -f /tmp/commithash1 && echo NOK'`

    return true if bashret.match(/NOK/)
    return false
  end

  # Clear ci locks
  #
  def clearci
    Rails.logger.warn("Remove ci locks for vm #{vm_name}")
    `ssh modem@#{floating_ip.shellescape} 'rm -f /tmp/commithash1 /tmp/commithash2'`
  end

  # Display postinstall script before approvement
  #
  # @return [Hash{Symbol => String, Number}] message from cmd and status code
  def postinstall_display
    docroot = "/var/www/#{project.name.shellescape}/"
    bashret = ''

    Rails.logger.warn("Postinstall display command for vm #{vm_name}")
    bashret = `ssh modem@#{floating_ip.shellescape} 'cd #{docroot};cat scripts/postinstall.sh'`

    # Return bash output
    { message: bashret, status: 200 }
  end

  # Display postinstall script before approvement
  #
  # @raise [NextDeployException] if errors occurs during lock handling
  # @return [Hash{Symbol => String, Number}] message from cmd and status code
  def postinstall
    docroot = "/var/www/#{project.name.shellescape}/"
    bashret = ''

    # take a lock for vm action
    begin
      open("/tmp/vm#{id}.lock", File::RDWR|File::CREAT) do |f|
        f.flock(File::LOCK_EX)

        Rails.logger.warn("Postinstall command for vm #{vm_name}")
        bashret = `ssh modem@#{floating_ip.shellescape} 'cd #{docroot};./scripts/./postinstall.sh'`
      end

    rescue
      raise Exceptions::NextDeployException.new("Lock on gitpull command for #{name} failed")
    end

    # Return bash output
    { message: bashret, status: 200 }
  end

  # Execute puppet agent into vm
  #
  # @raise [NextDeployException] if errors occurs during lock handling
  def puppet_refresh
    bash_cmd = 'sudo /usr/bin/puppet agent -t;(($? == 1)) && sleep 30 && sudo /usr/bin/puppet agent -t'

    # take a lock for vm action
    begin
      open("/tmp/vm#{id}.lock", File::RDWR|File::CREAT) do |f|
        f.flock(File::LOCK_EX)

        Rails.logger.warn(bash_cmd)
        system("ssh modem@#{floating_ip.shellescape} '#{bash_cmd}'")
      end

    rescue
      raise Exceptions::NextDeployException.new("Lock on puppetrefresh command for #{name} failed")
    end

  end

  # Return some vm logs
  #
  # @return [Hash{Symbol => String, Number}] message from cmd and status code
  def logs
    apache_logs = uris.flat_map(&:absolute).map do |absolute|
      "/var/log/apache2/#{absolute.shellescape}_access.log /var/log/apache2/#{absolute.shellescape}_error.log"
    end.join(' ')

    bash_cmd = "sudo tail -n 60 #{apache_logs} /var/log/mysql.err /var/log/mail.log"
    Rails.logger.warn("ssh modem@#{floating_ip} '#{bash_cmd}'")
    bashret = `ssh modem@#{floating_ip.shellescape} '#{bash_cmd}'`

    # Return bash output
    { message: bashret, status: 200 }
  end

  # Make a screenshot from main uri into the vm
  #
  # @raise [NextDeployException] if errors occurs during lock handling
  def webshot
    # take a lock for once shot at time
    begin
      open("/tmp/webshot.lock", File::RDWR|File::CREAT) do |f|
        f.flock(File::LOCK_EX)

        # Silently exceptions if error occurs
        suppress(Exception) do
          # Setup Capybara
          ws = Webshot::Screenshot.instance

          # Customize thumbnail
          uri = uris.first
          ws.capture "http://#{htlogin}:#{htpassword}@#{uri.absolute}/", "thumbs/#{id}.png",
                     width: 360, height: 240, quality: 85, timeout: 1,
                     allowed_status_codes: [200, 301, 302, 401, 403, 404, 500]
        end
      end

    rescue => e
      raise Exceptions::NextDeployException.new("Lock on webshot command for #{name} failed, #{e.message}")
    end

    generate_defaultwebshot unless File.exists?("thumbs/#{id}.png")
  end

  # Start a jenkins build on ci vm
  #
  # @raise [NextDeployException] if errors occurs during lock handling
  def buildtrigger
    bash_cmd = '/usr/bin/java -jar /usr/share/jenkins/jenkins-cli.jar -s http://localhost:9294 build build'
    Rails.logger.warn("ssh modem@#{floating_ip} '#{bash_cmd}'")
    `ssh modem@#{floating_ip.shellescape} '#{bash_cmd}'`
  end
end
