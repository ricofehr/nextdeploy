# Stores IO functions for uri Class
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
module UrisHelper
  # Crate nginx vhost file
  #
  # No param
  # No return
  def create_vhost
    # vhost is only for prod vms
    return true unless vm.is_prod

    aliasesparam = (!aliases || aliases.empty?) ? '' : " -s #{aliases.gsub(' ', ',')}"
    # todo: avoid bash cmd
    Rails.logger.warn "/bin/bash /ror/sbin/newvhost -i #{id} -a #{absolute}#{aliasesparam}"

    # take a lock for vm action
    begin
      open("/tmp/vhost.lock", File::RDWR|File::CREAT) do |f|
        f.flock(File::LOCK_EX)
        system("/bin/bash /ror/sbin/newvhost -i #{id} -a #{absolute}#{aliasesparam}")
      end

    rescue
      raise Exceptions::NextDeployException.new("Create vhost for #{absolute} failed")
    end

    true
  end

  # Delete nginx vhost file
  #
  # No param
  # No return
  def delete_vhost
    # todo: avoid bash cmd
    Rails.logger.warn "/bin/bash /ror/sbin/delvhost -i #{id}"
    # take a lock for vm action
    begin
      open("/tmp/vhost.lock", File::RDWR|File::CREAT) do |f|
        f.flock(File::LOCK_EX)
        system("/bin/bash /ror/sbin/delvhost -i #{id}")
      end

    rescue
      raise Exceptions::NextDeployException.new("Delete vhost for #{absolute} failed")
    end

    true
  end

  # Execute npm into vms
  #
  # No param
  # @return message for execution and codestatus for request
  def npm
    docroot = "/var/www/#{vm.project.name}/#{path}"
    frwname = framework.name.downcase
    bashret = ''

    Rails.logger.warn "Npm command for vm #{vm.name} (#{frwname})"

    # take a lock for vm action
    begin
      open("/tmp/vm#{vm.id}.lock", File::RDWR|File::CREAT) do |f|
        f.flock(File::LOCK_EX)
        bashret =`ssh modem@#{vm.floating_ip} 'npm.sh #{docroot}' 2>&1`
      end

    rescue
      raise Exceptions::NextDeployException.new("Lock on npm command for #{absolute} failed")
    end


    # Return bash output
    { message: bashret, status: 200 }
  end

  # Rebuild nodejs app into vms
  #
  # No param
  # @return message for execution and codestatus for request
  def nodejs
    docroot = "/var/www/#{vm.project.name}/#{path}"
    frwname = framework.name.downcase
    envvalues = envvars
    retapp = ''
    retserver = ''

    # build envvars string
    vm.uris.each { |uri2| envvalues.gsub!("%{URI_#{uri2.path.upcase}}", uri2.absolute) }

    Rails.logger.warn "Rebuild nodejs app for vm #{vm.name} (#{frwname})"

    # take a lock for vm action
    begin
      open("/tmp/vm#{vm.id}.lock", File::RDWR|File::CREAT) do |f|
        f.flock(File::LOCK_EX)

        `ssh modem@#{vm.floating_ip} 'cd #{docroot};touch /tmp/.lockpuppet;npm install 2>/tmp/lognpm;grep build package.json >/dev/null 2>&1 && npm run build 2>>/tmp/lognpm;pm2 delete #{path}-server;pm2 delete #{path}-app;'`
        retapp = `ssh modem@#{vm.floating_ip} 'cd #{docroot};[[ -f app.js ]] && #{envvalues} pm2 start -f app.js --name "#{path}-app" -i 0;'`
        retserver = `ssh modem@#{vm.floating_ip} '[[ -f /tmp/lognpm ]] && cat /tmp/lognpm;cd #{docroot};[[ -f server.js ]] && #{envvalues} pm2 start -f server.js --name "#{path}-server" -i 0;rm -f /tmp/.lockpuppet'`
      end

    rescue
      raise Exceptions::NextDeployException.new("Lock on nodejs command for #{absolute} failed")
    end

    # Return bash output
    { message: "#{retapp}#{retserver}", status: 200 }
  end

  # Rebuild reactjs app into vms
  #
  # No param
  # @return message for execution and codestatus for request
  def reactjs
    docroot = "/var/www/#{vm.project.name}/#{path}"
    frwname = framework.name.downcase
    envvalues = envvars
    retreactserver = ''
    retreactapi = ''

    # build envvars string
    vm.uris.each { |uri2| envvalues.gsub!("%{URI_#{uri2.path.upcase}}", uri2.absolute) }

    Rails.logger.warn "Rebuild reactjs app for vm #{vm.name} (#{frwname})"

    # take a lock for vm action
    begin
      open("/tmp/vm#{vm.id}.lock", File::RDWR|File::CREAT) do |f|
        f.flock(File::LOCK_EX)

        `ssh modem@#{vm.floating_ip} 'cd #{docroot};touch /tmp/.lockpuppet;npm install 2>/tmp/lognpm;npm run build 2>>/tmp/lognpm;pm2 delete #{path}-server;pm2 delete #{path}-api;'`
        retreactserver = `ssh modem@#{vm.floating_ip} '[[ -f /tmp/lognpm ]] && cat /tmp/lognpm;cd #{docroot};[[ -f bin/server.js ]] && #{envvalues} pm2 start -f bin/server.js --name "#{path}-server" -i 0;rm -f /tmp/.lockpuppet'`
        retreactapi = `ssh modem@#{vm.floating_ip} 'cd #{docroot};[[ -f bin/api.js ]] && #{envvalues} pm2 start -f bin/api.js --name "#{path}-api" -i 0'`
      end

    rescue
      raise Exceptions::NextDeployException.new("Lock on reactjs command for #{absolute} failed")
    end

    # Return bash output
    { message: "#{retreactserver}#{retreactapi}", status: 200 }
  end

  # Execute mvn into vms
  #
  # No param
  # @return message for execution and codestatus for request
  def mvn
    docroot = "/var/www/#{vm.project.name}/#{path}"
    frwname = framework.name.downcase
    bashret = ''

    Rails.logger.warn "Mvn command for vm #{vm.name} (#{frwname})"

    # take a lock for vm action
    begin
      open("/tmp/vm#{vm.id}.lock", File::RDWR|File::CREAT) do |f|
        f.flock(File::LOCK_EX)
        bashret = `ssh modem@#{vm.floating_ip} 'mvn.sh #{docroot}'`
      end

    rescue
      raise Exceptions::NextDeployException.new("Lock on mvn command for #{absolute} failed")
    end

    # Return bash output
    { message: bashret, status: 200 }
  end

  # Execute composer into vms
  #
  # No param
  # @return message for execution and codestatus for request
  def composer
    docroot = "/var/www/#{vm.project.name}/#{path}"
    frwname = framework.name.downcase
    bashret = ''

    Rails.logger.warn "Composer command for vm #{vm.name} (#{frwname})"

    # take a lock for vm action
    begin
      open("/tmp/vm#{vm.id}.lock", File::RDWR|File::CREAT) do |f|
        f.flock(File::LOCK_EX)
        bashret = `ssh modem@#{vm.floating_ip} 'composer.sh #{docroot} 2>&1'`
      end

    rescue
      raise Exceptions::NextDeployException.new("Lock on composer command for #{absolute} failed")
    end

    # Return bash output
    { message: bashret, status: 200 }
  end

  # Execute drush cmd into vms
  #
  # No param
  # @return message for execution and codestatus for request
  def drush(command)
    docroot = "/var/www/#{vm.project.name}/#{path}"
    frwname = framework.name.downcase
    bashret = ''

    Rails.logger.warn "Drush command for vm #{vm.name} (#{frwname})"
    
    # take a lock for vm action
    begin
      open("/tmp/vm#{vm.id}.lock", File::RDWR|File::CREAT) do |f|
        f.flock(File::LOCK_EX)
        bashret = `ssh modem@#{vm.floating_ip} 'cd #{docroot} && drush -y #{command} 2>&1'`
      end

    rescue
      raise Exceptions::NextDeployException.new("Lock on drush command for #{absolute} failed")
    end

    # Return bash output
    { message: bashret, status: 200 }
  end

  # Execute symfony cmd into vms
  #
  # No param
  # @return message for execution and codestatus for request
  def sfcmd(command)
    docroot = "/var/www/#{vm.project.name}/#{path}"
    frwname = framework.name.downcase
    bashret = ''

    Rails.logger.warn "Sf command for vm #{vm.name} (#{frwname})"

    # take a lock for vm action
    begin
      open("/tmp/vm#{vm.id}.lock", File::RDWR|File::CREAT) do |f|
        f.flock(File::LOCK_EX)
        bashret = `ssh modem@#{vm.floating_ip} 'cd #{docroot} && php app/console #{command} 2>&1'`
      end

    rescue
      raise Exceptions::NextDeployException.new("Lock on sf command for #{absolute} failed")
    end

    # Return bash output
    { message: bashret, status: 200 }
  end

  # Clear varnish cache
  #
  # No param
  # @return message for execution and codestatus for request
  def clearvarnish
    listaliases = aliases.split(" ")

    Rails.logger.warn "clear varnish for #{absolute}"
    bashret = `ssh modem@#{vm.floating_ip} 'varnishadm -T127.0.0.1:6082 ban req.http.host == #{absolute}'`

    # clear for aliases too
    listaliases.each {|aliase| system("ssh modem@#{vm.floating_ip} 'varnishadm -T127.0.0.1:6082 ban req.http.host == #{aliase}'") }

    # Fill message if is empty
    bashret = "Flushed for #{absolute}" if bashret.strip.empty?

    # Return bash output
    { message: bashret, status: 200 }
  end

  # Return some uri logs
  #
  # No param
  # @return message for execution and codestatus for request
  def logs
    docroot = "/var/www/#{vm.project.name}/#{path}"
    bashret = ''

    if framework.name.match(/^Symfony.*$/)
      Rails.logger.warn "ssh modem@#{vm.floating_ip} 'tail -n 50 #{docroot}/app/logs/*.log'"
      bashret = `ssh modem@#{vm.floating_ip} 'tail -n 50 #{docroot}/app/logs/*.log'`
    end

    if framework.name.match(/^Drupal.*$/)
      Rails.logger.warn "ssh modem@#{vm.floating_ip} 'cd #{docroot} && drush sqlq \"select message from watchdog\"'"
      #bashret = `ssh modem@#{vm.floating_ip} 'cd #{docroot} && drush sqlq "select message from watchdog"'`
    end

    if framework.name.match(/^NodeJS.*$/) || framework.name.match(/^ReactJS.*$/)
      Rails.logger.warn "ssh modem@#{vm.floating_ip} 'tail -n 50 /home/modem/.pm2/*.log /home/modem/.pm2/logs/*.log'"
      bashret = `ssh modem@#{vm.floating_ip} 'tail -n 50 /home/modem/.pm2/logs/*.log /home/modem/.pm2/pm2.log'`
    end

    # Return bash output
    { message: bashret, status: 200 }
  end

  # Execute import datas into vms
  #
  # No param
  # @return message for execution and codestatus for request
  def import
    docroot = "/var/www/#{vm.project.name}/"
    ftppasswd = vm.project.password
    ftpuser = vm.project.gitpath
    ismysql = vm.technos.any? { |t| t.name.include?('mysql') } ? 1 : 0
    ismongo = vm.technos.any? { |t| t.name.include?('mongo') } ? 1 : 0
    bashret = ''

    Rails.logger.warn "Import data for uri #{absolute}"

    # take a lock for project action
    begin
      open("/tmp/project#{vm.project.id}.lock", File::RDWR|File::CREAT) do |f|
        f.flock(File::LOCK_EX)
        bashret = `ssh modem@#{vm.floating_ip} 'cd #{docroot} && import.sh --uri #{absolute} --path #{path} --framework #{framework.name.downcase} --ftpuser #{ftpuser} --ftppasswd #{ftppasswd} --ismysql #{ismysql} --ismongo #{ismongo}'`
      end

    rescue
      raise Exceptions::NextDeployException.new("Lock on import command for #{absolute} failed")
    end

    #ret = bashret ? {message: "Ok", status: 200} : {message: "Error", status: 500}
    {message: bashret, status: 200}
  end

  # Execute export datas into vms
  #
  # No param
  # @return message for execution and codestatus for request
  def export(branchs)
    docroot = "/var/www/#{vm.project.name}/"
    ftppasswd = vm.project.password
    ftpuser = vm.project.gitpath
    ismysql = vm.technos.any? { |t| t.name.include?('mysql') } ? 1 : 0
    ismongo = vm.technos.any? { |t| t.name.include?('mongo') } ? 1 : 0
    bashret = ''

    Rails.logger.warn "Export data for vm #{absolute}"

    # take a lock for project action
    begin
      open("/tmp/project#{vm.project.id}.lock", File::RDWR|File::CREAT) do |f|
        f.flock(File::LOCK_EX)
        bashret = `ssh modem@#{vm.floating_ip} 'cd #{docroot} && export.sh --uri #{absolute} --path #{path} --framework #{framework.name.downcase} --ftpuser #{ftpuser} --ftppasswd #{ftppasswd} --ismysql #{ismysql} --ismongo #{ismongo} --branchs #{branchs}'`
      end

    rescue
      raise Exceptions::NextDeployException.new("Lock on export command for #{absolute} failed")
    end

    Rails.logger.warn "Error during Export data for vm #{absolute} !" if ! bashret

    #ret = bashret ? {message: "Ok", status: 200} : {message: "Error", status: 500}
    {message: bashret, status: 200}
  end

  # Execute project script
  #
  # No param
  # @return message for execution and codestatus for request
  def script(sfolder, sbin)
    docroot = "/var/www/#{vm.project.name}/#{path}/#{sfolder}"
    bashret = ''

    Rails.logger.warn "Execute script #{path}/#{sfolder}/#{sbin} for vm #{vm.name}"
    # take a lock for vm action
    begin
      open("/tmp/vm#{vm.id}.lock", File::RDWR|File::CREAT) do |f|
        f.flock(File::LOCK_EX)
        bashret = `ssh modem@#{vm.floating_ip} 'cd #{docroot};./#{sbin}'`
      end

    rescue
      raise Exceptions::NextDeployException.new("Lock on script command for #{name} failed")
    end

    # Return bash output
    { message: bashret, status: 200 }
  end

  # List project scripts
  #
  # No param
  # @return message for execution and codestatus for request
  def listscript
    docroot = "/var/www/#{vm.project.name}/#{path}"
    bashret = `ssh modem@#{vm.floating_ip} 'cd #{docroot} && findscripts.sh'`
    
    # Return bash output
    { message: bashret, status: 200 }
  end

end
