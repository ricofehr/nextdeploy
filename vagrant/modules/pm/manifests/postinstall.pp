# == Class: pm::postinstall::exploitation
#
# Some commands creation for make exploitation easier
#
#
# === Authors
#
# Eric Fehr <eric.fehr@publicis-modem.fr>
#
class pm::postinstall::exploitation {
  $railsenv = hiera('global::railsenv', 'development')

  Exec {
      path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/rvm/bin:/opt/ruby/bin/',
      user => 'root',
  }

  # puma service management
  file { '/usr/local/bin/puma-status':
    ensure => file,
    source => ['puppet:///modules/pm/scripts/puma-status'],
    owner => 'root',
    mode => '0755',
    group => 'root'
  }

  file { '/usr/local/bin/puma-stop':
    ensure => file,
    source => ['puppet:///modules/pm/scripts/puma-stop'],
    owner => 'root',
    mode => '0755',
    group => 'root'
  }

  file { '/usr/local/bin/puma-restart':
    ensure => file,
    source => ['puppet:///modules/pm/scripts/puma-restart'],
    owner => 'root',
    mode => '0755',
    group => 'root'
  }

  file { '/usr/local/bin/puma-start':
    ensure => file,
    source => ["puppet:///modules/pm/scripts/puma-start_${clientcert}",
      'puppet:///modules/pm/scripts/puma-start'],
    owner => 'root',
    mode => '0755',
    group => 'root'
  } ->
  exec { 'pumaenv':
    command => "/bin/sed -i 's;%%RAILSENV%%;${railsenv};' /usr/local/bin/puma-start",
    onlyif => 'grep RAILSENV /usr/local/bin/puma-start',
    user => 'root' 
  }

  # genera application ember file
  file { '/usr/local/bin/rebuildember':
    ensure => file,
    source => ['puppet:///modules/pm/scripts/rebuildember'],
    owner => 'root',
    mode => '0755',
    group => 'root'
  }

  # restart dnsmasq script
  file { '/usr/local/bin/rdnsmasq':
    ensure => 'file',
    content => '#!/bin/bash
hostsmin=$(find /etc/hosts.nextdeploy -mmin -1)
[[ -n $hostsmin ]] && service dnsmasq force-reload',
    owner => 'root',
    mode => '0700',
    group => 'root'
  }

  # update nextdeploy project from github repository
  file { '/usr/local/bin/updatenextdeploy':
    ensure => 'file',
    source => ['puppet:///modules/pm/scripts/updatenextdeploy'],
    owner => 'root',
    mode => '0755',
    group => 'root'
  }

  # execute rake:migrate command on the ror rest project
  file { '/usr/local/bin/migratenextdeploy':
    ensure => 'file',
    source => ['puppet:///modules/pm/scripts/migratenextdeploy'],
    owner => 'root',
    mode => '0755',
    group => 'root'
  }

  # execute bundle install command on the ror rest project
  file { '/usr/local/bin/bundlenextdeploy':
    ensure => 'file',
    source => ['puppet:///modules/pm/scripts/bundlenextdeploy'],
    owner => 'root',
    mode => '0755',
    group => 'root'
  }

  # generate ror documentation
  file { '/usr/local/bin/yardoc':
    ensure => 'file',
    source => ['puppet:///modules/pm/scripts/yardoc'],
    owner => 'root',
    mode => '0755',
    group => 'root'
  }
  
  # backup nextdeploy
  file { '/usr/local/bin/backupnextdeploy':
    ensure => 'file',
    source => ['puppet:///modules/pm/scripts/backupnextdeploy'],
    owner => 'root',
    mode => '0755',
    group => 'root'
  }

}

# == Class: pm::postinstall::nextdeploy
#
# Some commands and setting for finalize installation of manager node for nextdeploy platform
#
#
# === Authors
#
# Eric Fehr <eric.fehr@publicis-modem.fr>
#
class pm::postinstall::nextdeploy {
  $railsenv = hiera('global::railsenv', 'development')

  Exec {
      path => '/usr/local/rvm/gems/ruby-2.1.0/bin:/usr/local/rvm/gems/ruby-2.1.0@global/bin:/usr/local/rvm/rubies/ruby-2.1.0/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/rvm/bin:/opt/ruby/bin/',
      user => 'modem',
      environment => [
          'rvm_bin_path=/usr/local/rvm/bin',
          'SHELL=/bin/bash',
          'USER=modem',
          'rvm_path=/usr/local/rvm',
          'rvm_prefix=/usr/local',
          'LANG=en_US.utf8',
          'HOME=/home/modem',
          'LANGUAGE=en_US',
          "RAILS_ENV=${railsenv}",
          'GEM_HOME=/usr/local/rvm/gems/ruby-2.1.0',
          'IRBRC=/usr/local/rvm/rubies/ruby-2.1.0/.irbrc',
          'MY_RUBY_HOME=/usr/local/rvm/rubies/ruby-2.1.0',
          'GEM_PATH=/usr/local/rvm/gems/ruby-2.1.0:/usr/local/rvm/gems/ruby-2.1.0@global',
          'RUBY_VERSION=ruby-2.1.0'
      ],
      cwd => '/ror'
  }

  # enable ip forwarding
  sysctl::value { "net.ipv4.ip_forward": value => "1"}

  # prepare vpnkeys folder
  exec { 'copyindextxt':
    command => 'cp -f /etc/openvpn/nextdeploy/easy-rsa/keys/index.txt /ror/vpnkeys/index.txt',
    user => 'root',
    creates => '/home/modem/.installnextdeploy'
  } ->

  exec { 'copyserial':
    command => 'cp -f /etc/openvpn/nextdeploy/easy-rsa/keys/serial /ror/vpnkeys/serial',
    user => 'root',
    creates => '/home/modem/.installnextdeploy'
  } ->

  exec { 'copycakey':
    command => 'cp -f /etc/openvpn/nextdeploy/easy-rsa/keys/ca.key /ror/vpnkeys/ca.key',
    user => 'root',
    creates => '/home/modem/.installnextdeploy'
  } ->

  exec { 'copycacrt':
    command => 'cp -f /etc/openvpn/nextdeploy/easy-rsa/keys/ca.crt /ror/vpnkeys/ca.crt',
    user => 'root',
    creates => '/home/modem/.installnextdeploy'
  } ->

  exec { 'copywhichopenssl':
    command => 'cp -f /etc/openvpn/nextdeploy/easy-rsa/whichopensslcnf /ror/vpnkeys/bin/whichopensslcnf',
    user => 'root',
    creates => '/home/modem/.installnextdeploy'
  } ->

  exec { 'copyopenssl098':
    command => 'cp -f /etc/openvpn/nextdeploy/easy-rsa/openssl-0.9.8.cnf /ror/vpnkeys/bin/openssl-0.9.8.cnf',
    user => 'root',
    creates => '/home/modem/.installnextdeploy'
  } ->

  exec { 'copyopenssl100':
    command => 'cp -f /etc/openvpn/nextdeploy/easy-rsa/openssl-1.0.0.cnf /ror/vpnkeys/bin/openssl-1.0.0.cnf',
    user => 'root',
    creates => '/home/modem/.installnextdeploy'
  } ->

  exec { 'copyopenssl096':
    command => 'cp -f /etc/openvpn/nextdeploy/easy-rsa/openssl-0.9.6.cnf /ror/vpnkeys/bin/openssl-0.9.6.cnf',
    user => 'root',
    creates => '/home/modem/.installnextdeploy'
  } ->

  exec { 'copyopenssl':
    command => 'cp -f /etc/openvpn/nextdeploy/easy-rsa/openssl.cnf /ror/vpnkeys/bin/openssl.cnf',
    user => 'root',
    creates => '/home/modem/.installnextdeploy'
  } ->

  exec { 'copypkitool':
    command => 'cp -f /etc/openvpn/nextdeploy/easy-rsa/pkitool /ror/vpnkeys/bin/pkitool',
    user => 'root',
    creates => '/home/modem/.installnextdeploy'
  } ->

  exec { 'chownmodemvpnkeys':
    command => 'chown -R modem: /ror/vpnkeys',
    user => 'root',
    creates => '/home/modem/.installnextdeploy'
  } ->

  # redirect gitlab to https
  file_line { 'gitlabhttps':
    path => '/var/opt/gitlab/nginx/conf/gitlab-http.conf',
    line => 'server_tokens off; if ($http_x_forwarded_proto != "https") { rewrite ^(.*)$ https://$server_name$1 permanent; }',
    match => '.*server_tokens off;.*',
    multiple => false
  }  ->

  # patch gitlab for auto-confirm users
  file { '/opt/gitlab/embedded/service/gitlab-rails/lib/api/users.rb':
    ensure => file,
    source => ['puppet:///modules/pm/gitlab/users.rb'],
    owner => 'modem',
    mode => '0664',
    require => Exec['gitlab_reconfigure']
  } ->

  # some custom settings for gitlab
  exec { 'gitlabusersetting':
    command => '/opt/gitlab/embedded/bin/psql -h /var/opt/gitlab/postgresql -d gitlabhq_production -c "UPDATE application_settings SET signup_enabled=\'f\',max_attachment_size=60, default_projects_limit=0;"',
    user => 'gitlab-psql',
    creates => '/home/modem/.installnextdeploy'
  } ->

  # restart gitlab
  exec { 'restartgitalb':
    command => '/usr/bin/gitlab-ctl restart',
    user => 'root',
    creates => '/home/modem/.installnextdeploy'
  } ->

  # ensure that ror and out folders is on modem owner
  # temporary before git repo will be public
  exec { 'chownmodem':
    command => 'chown -R modem: /home/nextdeploy',
    onlyif => 'test -d /home/nextdeploy',
    user => 'root',
    creates => '/home/modem/.installnextdeploy'
  } ->

  # disable hostkey verification on nextdeploy
  file_line { 'disable_hostchecking_ssh':
    path => '/etc/ssh/ssh_config',
    line => 'StrictHostKeyChecking no'
  } ->

  # git config email
  exec { 'gitconfig1':
    command => 'git config --global user.email admin@example.com',
    creates => '/home/modem/.installnextdeploy'
  } ->

  # git config username
  exec { 'gitconfig2':
    command => 'git config --global user.name root',
    creates => '/home/modem/.installnextdeploy'
  } ->

  # prepare ror website
  exec { 'bundle-clean':
    command => 'rm -rf vendor/bundle/*',
    creates => '/home/modem/.installnextdeploy'
  } ->

  # clean sshkeys
  exec { 'sshkeys-clean':
    command => 'rm -f sshkeys/*',
    creates => '/home/modem/.installnextdeploy'
  } ->

  # clean privatetoken
  exec { 'token-clean':
    command => 'rm -f tmp/private_token',
    creates => '/home/modem/.installnextdeploy'
  } ->

  # need sudo for manage ftp users
  file_line { 'sudo_rule':
    path => '/etc/sudoers',
    line => 'modem ALL=(root) NOPASSWD: /usr/local/bin/./nextdeploy-*',
  } ->

  # install ruby bundles
  exec { 'bundle-ror':
    command => 'bundle install --path vendor/bundle > /out/logbundle.log 2>&1',
    timeout => 0,
    creates => '/home/modem/.installnextdeploy',
    require => [ Package['libmysqlclient-dev'], Class['rvm'], Class['memcached'] ]
  } ->

  # database installation
  exec { 'db-schema':
    command => 'rake db:schema:load > /out/logdbschema.log 2>&1',
    timeout => 0,
    creates => '/home/modem/.installnextdeploy'
  } ->

  exec { 'db-migrate':
    command => 'rake db:migrate > /out/logdbmigrate.log 2>&1',
    timeout => 0,
    creates => '/home/modem/.installnextdeploy'
  } ->

  exec { 'db-seed':
    command => 'rake db:seed > /out/logdbseed.log 2>&1',
    timeout => 0,
    creates => '/home/modem/.installnextdeploy',
    require => File['/bin/sh']
  } ->

  # ensure puma folder is here for create socket
  file { '/var/run/puma':
    ensure =>  directory,
    owner => 'modem',
    mode => '0777'
  } ->

  # ensure /var/run/puma create on each reboot
  file_line { 'pumarclocal':
    path => '/etc/rc.local',
    line => 'mkdir -p /var/run/puma && chown modem: /var/run/puma',
    match => '^$',
    multiple => false
  } ->

  # generate doc
  exec { 'yardoc_ror':
    command => 'bundle exec yardoc lib/**/*.rb app/**/*.rb config/**/*.rb',
    timeout => 120,
    creates => '/home/modem/.installnextdeploy'
  } ->

  file { '/hiera':
    ensure => 'link',
    target => '/ror/hiera',
    owner => 'root',
  } ->

  exec { 'touchinstallnextdeploy':
    command => 'touch /home/modem/.installnextdeploy',
    creates => '/home/modem/.installnextdeploy'
  }

  # nodejs and ember_build prerequisites
  class { 'nodejs':
    manage_package_repo       => false,
    nodejs_dev_package_ensure => 'present',
    npm_package_ensure        => 'present',
  } ->
  
  file { '/usr/bin/node':
    ensure   => 'link',
    target => '/usr/bin/nodejs',
  } ->

  package { 'fsmonitor':
    ensure   => present,
    provider => 'npm',
    require => Exec['apt-update']
  } ->

  package { 'ember-tools':
    ensure   => present,
    provider => 'npm',
    require => Exec['apt-update']
  }
}
