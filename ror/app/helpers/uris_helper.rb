# Stores IO functions for uri Class
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
module UrisHelper
  # Create nginx vhost file
  #
  # @raise [NextDeployException] if errors occurs during vhost writing
  # @return [Boolean] if successful
  def create_vhost
    # vhost is only for prod vms
    return true unless vm.prod?

    aliasesparam = (!aliases || aliases.empty?) ? '' : " -s #{aliases.gsub(' ', ',').shellescape}"
    bash_cmd = "/bin/bash /ror/sbin/newvhost -i #{id} " +
               "-a #{absolute.shellescape}#{aliasesparam}"

    # take a lock for vm action
    begin
      open("/tmp/vhost.lock", File::RDWR|File::CREAT) do |f|
        f.flock(File::LOCK_EX)

        Rails.logger.warn(bash_cmd)
        system(bash_cmd)
      end

    rescue
      raise Exceptions::NextDeployException.new("Create vhost for #{absolute} failed")
    end

    true
  end

  # Delete nginx vhost file
  #
  # @raise [NextDeployException] if errors occurs during vhost deleting
  # @return [Boolean] if successful
  def delete_vhost
    bash_cmd = "/bin/bash /ror/sbin/delvhost -i #{id}"

    # take a lock for vm action
    begin
      open("/tmp/vhost.lock", File::RDWR|File::CREAT) do |f|
        f.flock(File::LOCK_EX)

        Rails.logger.warn(bash_cmd)
        system(bash_cmd)
      end

    rescue
      raise Exceptions::NextDeployException.new("Delete vhost for #{absolute} failed")
    end

    true
  end

  # Execute npm into vms
  #
  # @raise [NextDeployException] if errors occurs during lock handling
  # @return [Hash{Symbol => String, Number}] message from cmd and status code
  def npm
    docroot = "/var/www/#{vm.project.name.shellescape}/#{path.shellescape}"
    frwname = framework.name.downcase
    bashret = ''

    # take a lock for vm action
    begin
      open("/tmp/vm#{vm.id}.lock", File::RDWR|File::CREAT) do |f|
        f.flock(File::LOCK_EX)

        Rails.logger.warn("Npm command for vm #{vm.name} (#{frwname})")
        bashret =`ssh modem@#{vm.floating_ip.shellescape} 'npm.sh #{docroot}' 2>&1`
      end

    rescue
      raise Exceptions::NextDeployException.new("Lock on npm command for #{absolute} failed")
    end


    # Return bash output
    { message: bashret, status: 200 }
  end

  # Rebuild nodejs app into vms
  #
  # @raise [NextDeployException] if errors occurs during lock handling
  # @return [Hash{Symbol => String, Number}] message from cmd and status code
  def nodejs
    docroot = "/var/www/#{vm.project.name.shellescape}/#{path.shellescape}"
    framework_name = framework.name.downcase
    envvalues = envvars.split(' ').map { |ev| ev.split('=').map { |ev2| ev2.shellescape }.join('=') }.join(' ')
    retapp = ''
    retserver = ''

    cnt_instances = 1
    if envvars.match('CLUSTERING=')
      cnt_instances = envvars.gsub(/^.*CLUSTERING=/,'').gsub(/ .*$/,'').to_i
    end

    # build envvars string
    vm.uris.each { |uri2| envvalues.gsub!("%{URI_#{uri2.path.shellescape.upcase}}", uri2.absolute) }

    # Bash commands list
    bash_cmd_build = "cd #{docroot};touch /tmp/.lockpuppet;npm install 2>/tmp/lognpm;" +
                     "grep build package.json >/dev/null 2>&1 && npm run build 2>>/tmp/lognpm;" +
                     "pm2 delete #{path.shellescape}-server;pm2 delete #{path.shellescape}-app;"

    bash_cmd_start_app = "cd #{docroot};[[ -f app.js ]] && #{envvalues} " +
                         "pm2 start -f app.js --name \"#{path.shellescape}-app\" -i #{cnt_instances};"

    bash_cmd_start_server = "[[ -f /tmp/lognpm ]] && cat /tmp/lognpm;cd #{docroot};" +
                            "[[ -f server.js ]] && #{envvalues} pm2 start -f server.js " +
                            "--name \"#{path.shellescape}-server\" -i #{cnt_instances};rm -f /tmp/.lockpuppet"

    # take a lock for vm action
    begin
      open("/tmp/vm#{vm.id}.lock", File::RDWR|File::CREAT) do |f|
        f.flock(File::LOCK_EX)

        Rails.logger.warn("Rebuild nodejs app for vm #{vm.name} (#{framework_name})")
        `ssh modem@#{vm.floating_ip.shellescape} '#{bash_cmd_build}'`
        retapp = `ssh modem@#{vm.floating_ip.shellescape} '#{bash_cmd_start_app}'`
        retserver = `ssh modem@#{vm.floating_ip.shellescape} '#{bash_cmd_start_server}'`
      end

    rescue
      raise Exceptions::NextDeployException.new("Lock on nodejs command for #{absolute} failed")
    end

    # Return bash output
    { message: "#{retapp}#{retserver}", status: 200 }
  end

  # Rebuild reactjs app into vms
  #
  # @raise [NextDeployException] if errors occurs during lock handling
  # @return [Hash{Symbol => String, Number}] message from cmd and status code
  def reactjs
    docroot = "/var/www/#{vm.project.name.shellescape}/#{path.shellescape}"
    framework_name = framework.name.downcase
    envvalues = envvars.split(' ').map { |ev| ev.split('=').map { |ev2| ev2.shellescape }.join('=') }.join(' ')
    retreactserver = ''
    retreactapi = ''

    cnt_instances = 1
    if envvars.match('CLUSTERING=')
      cnt_instances = envvars.gsub(/^.*CLUSTERING=/,'').gsub(/ .*$/,'').to_i
    end

    # build envvars string
    vm.uris.each { |uri2| envvalues.gsub!("%{URI_#{uri2.path.shellescape.upcase}}", uri2.absolute) }

    # Bash commands list
    bash_cmd_build = "cd #{docroot};touch /tmp/.lockpuppet;npm install 2>/tmp/lognpm;" +
                     "npm run build 2>>/tmp/lognpm;pm2 delete #{path.shellescape}-server;" +
                     "pm2 delete #{path.shellescape}-api;"

    bash_cmd_start_server = "[[ -f /tmp/lognpm ]] && cat /tmp/lognpm;cd #{docroot};" +
                            "[[ -f bin/server.js ]] && #{envvalues} " +
                            "pm2 start -f bin/server.js --name \"#{path.shellescape}-server\" " +
                            "-i #{cnt_instances}"

    bash_cmd_start_api = "cd #{docroot};[[ -f bin/api.js ]] && #{envvalues} " +
                         "pm2 start -f bin/api.js --name \"#{path.shellescape}-api\" " +
                         "-i #{cnt_instances};rm -f /tmp/.lockpuppet"

    # take a lock for vm action
    begin
      open("/tmp/vm#{vm.id}.lock", File::RDWR|File::CREAT) do |f|
        f.flock(File::LOCK_EX)

        Rails.logger.warn("Rebuild reactjs app for vm #{vm.name} (#{framework_name})")
        `ssh modem@#{vm.floating_ip.shellescape} '#{bash_cmd_build}'`
        retreactserver = `ssh modem@#{vm.floating_ip.shellescape} '#{bash_cmd_start_server}'`
        retreactapi = `ssh modem@#{vm.floating_ip.shellescape} '#{bash_cmd_start_api}'`
      end

    rescue
      raise Exceptions::NextDeployException.new("Lock on reactjs command for #{absolute} failed")
    end

    # Return bash output
    { message: "#{retreactserver}#{retreactapi}", status: 200 }
  end

  # Execute mvn into vms
  #
  # @raise [NextDeployException] if errors occurs during lock handling
  # @return [Hash{Symbol => String, Number}] message from cmd and status code
  def mvn
    docroot = "/var/www/#{vm.project.name.shellescape}/#{path.shellescape}"
    frwname = framework.name.downcase
    bashret = ''

    Rails.logger.warn("Mvn command for vm #{vm.name} (#{frwname})")

    # take a lock for vm action
    begin
      open("/tmp/vm#{vm.id}.lock", File::RDWR|File::CREAT) do |f|
        f.flock(File::LOCK_EX)

        bashret = `ssh modem@#{vm.floating_ip.shellescape} 'mvn.sh #{docroot}'`
      end

    rescue
      raise Exceptions::NextDeployException.new("Lock on mvn command for #{absolute} failed")
    end

    # Return bash output
    { message: bashret, status: 200 }
  end

  # Execute composer into vms
  #
  # @raise [NextDeployException] if errors occurs during lock handling
  # @return [Hash{Symbol => String, Number}] message from cmd and status code
  def composer
    docroot = "/var/www/#{vm.project.name.shellescape}/#{path.shellescape}"
    frwname = framework.name.downcase
    bashret = ''

    # take a lock for vm action
    begin
      open("/tmp/vm#{vm.id}.lock", File::RDWR|File::CREAT) do |f|
        f.flock(File::LOCK_EX)

        Rails.logger.warn("Composer command for vm #{vm.name} (#{frwname})")
        bashret = `ssh modem@#{vm.floating_ip.shellescape} 'composer.sh #{docroot} 2>&1'`
      end

    rescue
      raise Exceptions::NextDeployException.new("Lock on composer command for #{absolute} failed")
    end

    # Return bash output
    { message: bashret, status: 200 }
  end

  # Execute drush cmd into vms
  #
  # @raise [NextDeployException] if errors occurs during lock handling
  # @return [Hash{Symbol => String, Number}] message from cmd and status code
  def drush(command)
    docroot = "/var/www/#{vm.project.name.shellescape}/#{path.shellescape}"
    bashret = ''

    # take a lock for vm action
    begin
      open("/tmp/vm#{vm.id}.lock", File::RDWR|File::CREAT) do |f|
        f.flock(File::LOCK_EX)

        Rails.logger.warn("Drush command for vm #{vm.name}")
        bashret = `ssh modem@#{vm.floating_ip.shellescape} 'cd #{docroot} && drush -y #{command.shellescape} 2>&1'`
      end

    rescue
      raise Exceptions::NextDeployException.new("Lock on drush command for #{absolute} failed")
    end
    # Return bash output
    { message: bashret, status: 200 }
  end

  # Execute site-install cmd into vms
  #
  # @raise [NextDeployException] if errors occurs during lock handling
  # @return [Hash{Symbol => String, Number}] message from cmd and status code
  def siteinstall
    docroot = "/var/www/#{vm.project.name.shellescape}/#{path.shellescape}"
    bashret = ''

    bash_cmd = "cd #{docroot} && chmod +w sites/default && " +
               "chmod +w sites/default/settings.php && siteinstall.sh " +
               "--docroot #{docroot} --eppath #{path.shellescape} --username #{vm.htlogin.shellescape} " +
               "--adminpass #{vm.htpassword.shellescape} --project #{vm.project.name.shellescape} " +
               "--email #{vm.user.email.shellescape} && cat /home/modem/logsiteinstall 2>&1"

    # take a lock for vm action
    begin
      open("/tmp/vm#{vm.id}.lock", File::RDWR|File::CREAT) do |f|
        f.flock(File::LOCK_EX)

        Rails.logger.warn("Siteinstall command for vm #{vm.name}")
        bashret = `ssh modem@#{vm.floating_ip.shellescape} '#{bash_cmd}'`
      end

    rescue
      raise Exceptions::NextDeployException.new("Lock on siteinstall command for #{absolute} failed")
    end

    # Return bash output
    { message: bashret, status: 200 }
  end

  # Execute symfony cmd into vms
  #
  # @raise [NextDeployException] if errors occurs during lock handling
  # @return [Hash{Symbol => String, Number}] message from cmd and status code
  def sfcmd(command)
    docroot = "/var/www/#{vm.project.name.shellescape}/#{path.shellescape}"
    frwname = framework.name.downcase
    bashret = ''

    bash_cmd = "cd #{docroot};[[ -f app/console ]] && php app/console #{command.shellescape}; " +
               "[[ -f bin/console ]] && php bin/console #{command.shellescape} 2>&1"

    # take a lock for vm action
    begin
      open("/tmp/vm#{vm.id}.lock", File::RDWR|File::CREAT) do |f|
        f.flock(File::LOCK_EX)

        Rails.logger.warn("Sf command for vm #{vm.name} (#{frwname})")
        bashret = `ssh modem@#{vm.floating_ip.shellescape} '#{bash_cmd}'`
      end

    rescue
      raise Exceptions::NextDeployException.new("Lock on sf command for #{absolute} failed")
    end

    # Return bash output
    { message: bashret, status: 200 }
  end

  # Clear varnish cache
  #
  # @return [Hash{Symbol => String, Number}] message from cmd and status code
  def clearvarnish
    listaliases = aliases.split(" ")

    Rails.logger.warn("clear varnish for #{absolute}")
    bashret = `ssh modem@#{vm.floating_ip.shellescape} 'varnishadm -T127.0.0.1:6082 ban req.http.host == #{absolute.shellescape}'`

    # clear for aliases too
    listaliases.each do |aliase|
      system("ssh modem@#{vm.floating_ip.shellescape} 'varnishadm -T127.0.0.1:6082 ban req.http.host == #{aliase.shellescape}'")
    end

    # Fill message if is empty
    bashret = "Flushed for #{absolute}" if bashret.strip.empty?

    # Return bash output
    { message: bashret, status: 200 }
  end

  # Return some uri logs
  #
  # @return [Hash{Symbol => String, Number}] message from cmd and status code
  def logs
    docroot = "/var/www/#{vm.project.name.shellescape}/#{path.shellescape}"
    bashret = ''

    if framework.name.match(/^Symfony.*$/)
      bash_cmd = "tail -n 50 #{docroot}/app/logs/*.log"
      Rails.logger.warn("ssh modem@#{vm.floating_ip.shellescape} '#{bash_cmd}'")
      bashret = `ssh modem@#{vm.floating_ip.shellescape} '#{bash_cmd}'`
    end

    if framework.name.match(/^Drupal.*$/)
      bash_cmd = "cd #{docroot} && drush sqlq \"select message from watchdog\""
      Rails.logger.warn("ssh modem@#{vm.floating_ip.shellescape} '#{bash_cmd}'")
      #bashret = `ssh modem@#{vm.floating_ip} '#{bash_cmd}'`
    end

    if framework.name.match(/^NodeJS.*$/) || framework.name.match(/^ReactJS.*$/)
      bash_cmd = 'tail -n 50 /home/modem/.pm2/*.log /home/modem/.pm2/logs/*.log'
      Rails.logger.warn("ssh modem@#{vm.floating_ip.shellescape} '#{bash_cmd}'")
      bashret = `ssh modem@#{vm.floating_ip.shellescape} '#{bash_cmd}'`
    end

    # Return bash output
    { message: bashret, status: 200 }
  end

  # Execute import datas into vms
  #
  # @raise [NextDeployException] if errors occurs during lock handling
  # @return [Hash{Symbol => String, Number}] message from cmd and status code
  def import
    docroot = "/var/www/#{vm.project.name.shellescape}/"
    ftppasswd = vm.project.password
    ftpuser = vm.project.gitpath
    ismysql = vm.technos.any? { |t| t.name.include?('mysql') } ? 1 : 0
    ismongo = vm.technos.any? { |t| t.name.include?('mongo') } ? 1 : 0
    bashret = ''

    bash_cmd = "cd #{docroot} && import.sh --uri #{absolute.shellescape} --path #{path.shellescape} " +
               "--framework #{framework.name.shellescape.downcase} --ftpuser #{ftpuser.shellescape} " +
               "--ftppasswd #{ftppasswd.shellescape} --ismysql #{ismysql} --ismongo #{ismongo}"

    # take a lock for project action
    begin
      open("/tmp/project#{vm.project.id}.lock", File::RDWR|File::CREAT) do |f|
        f.flock(File::LOCK_EX)

        Rails.logger.warn("Import data for uri #{absolute}")
        bashret = `ssh modem@#{vm.floating_ip.shellescape} '#{bash_cmd}'`
      end

    rescue
      raise Exceptions::NextDeployException.new("Lock on import command for #{absolute} failed")
    end

    #ret = bashret ? {message: "Ok", status: 200} : {message: "Error", status: 500}
    {message: bashret, status: 200}
  end

  # Execute export datas into vms
  #
  # @param branchs [Array<String>] branchs list to target for export
  # @raise [NextDeployException] if errors occurs during lock handling
  # @return [Hash{Symbol => String, Number}] message from cmd and status code
  def export(branchs)
    docroot = "/var/www/#{vm.project.name.shellescape}/"
    ftppasswd = vm.project.password
    ftpuser = vm.project.gitpath
    ismysql = vm.technos.any? { |t| t.name.include?('mysql') } ? 1 : 0
    ismongo = vm.technos.any? { |t| t.name.include?('mongo') } ? 1 : 0
    bashret = ''

    bash_cmd = "cd #{docroot} && export.sh --uri #{absolute.shellescape} --path #{path.shellescape} " +
               "--framework #{framework.name.shellescape.downcase} --ftpuser #{ftpuser.shellescape} " +
               "--ftppasswd #{ftppasswd.shellescape} --ismysql #{ismysql} " +
               "--ismongo #{ismongo} --branchs #{branchs.shellescape}"

    # take a lock for project action
    begin
      open("/tmp/project#{vm.project.id}.lock", File::RDWR|File::CREAT) do |f|
        f.flock(File::LOCK_EX)

        Rails.logger.warn("Export data for vm #{absolute}")
        bashret = `ssh modem@#{vm.floating_ip.shellescape} '#{bash_cmd}'`
      end

    rescue
      raise Exceptions::NextDeployException.new("Lock on export command for #{absolute} failed")
    end

    Rails.logger.warn("Error during Export data for vm #{absolute} !") if !bashret

    {message: bashret, status: 200}
  end

  # Execute project script
  #
  # @raise [NextDeployException] if errors occurs during lock handling
  # @return [Hash{Symbol => String, Number}] message from cmd and status code
  def script(sfolder, sbin)
    docroot = "/var/www/#{vm.project.name.shellescape}/#{path.shellescape}/#{sfolder.split('/').map { |folder| folder.shellescape }.join('/')}"
    bashret = ''

    # take a lock for vm action
    begin
      open("/tmp/vm#{vm.id}.lock", File::RDWR|File::CREAT) do |f|
        f.flock(File::LOCK_EX)

        Rails.logger.warn("Execute script #{path}/#{sfolder}/#{sbin} for vm #{vm.name}")
        bashret = `ssh modem@#{vm.floating_ip.shellescape} 'cd #{docroot};./#{sbin.shellescape}'`
      end

    rescue
      raise Exceptions::NextDeployException.new("Lock on script command for #{name} failed")
    end

    # Return bash output
    { message: bashret, status: 200 }
  end

  # List project scripts
  #
  # @return [Hash{Symbol => String, Number}] message from cmd and status code
  def listscript
    docroot = "/var/www/#{vm.project.name.shellescape}/#{path.shellescape}"
    bashret = `ssh modem@#{vm.floating_ip.shellescape} 'cd #{docroot} && findscripts.sh'`

    # Return bash output
    { message: bashret, status: 200 }
  end
end
