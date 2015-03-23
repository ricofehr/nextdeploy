# == Class: pm::postinstall::mvmc
#
# Some commands and setting for finalize installation of manager node for mvmc platform
#
#
# === Authors
#
# Eric Fehr <eric.fehr@publicis-modem.fr>
#
class pm::postinstall::mvmc {
  $railsenv = hiera('railsenv', 'development')

  Exec {
      path => '/usr/local/rvm/gems/ruby-2.1.0/bin:/usr/local/rvm/gems/ruby-2.1.0@global/bin:/usr/local/rvm/rubies/ruby-2.1.0/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/rvm/bin:/opt/ruby/bin/',
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
  
  # ensure that ror and out folders is on modem owner
  # temporary before git repo will be public
  exec { 'chownmodem':
    command => 'chown -R modem: /home/mvmc',
    onlyif => 'test -d /home/mvmc',
    user => 'root'
  } ->
  # disable hostkey verification on mvmc
  file_line { 'disable_hostchecking_ssh':
    path => '/etc/ssh/ssh_config',
    line => 'StrictHostKeyChecking no'
  } ->
  # add mode into sudo users
  file_line { 'sudo_rule':
    path => '/etc/sudoers',
    line => 'modem ALL=(ALL) NOPASSWD: ALL',
  } ->
  file_line { 'sudo_env':
    path => '/etc/sudoers',
    line => 'Defaults env_reset,always_set_home',
    match => '.*env_reset.*'
  } ->
  # git config email
  exec { 'gitconfig1':
    command => 'git config --global user.email usera@os.mvmc'
  } ->
  # git config username
  exec { 'gitconfig2':
    command => 'git config --global user.name admin'
  } ->
  # prepare ror website
  exec { 'bundle-clean':
    command => 'rm -rf vendor/bundle/*'
  } ->
  # clean sshkeys
  exec { 'sshkeys-clean':
    command => 'rm -f sshkeys/*'
  } ->
  # clean privatetoken
  exec { 'token-clean':
    command => 'rm -f tmp/private_token'
  } ->
  exec { 'bundle-ror':
    command => 'bundle install --path vendor/bundle > /out/logbundle.log 2>&1',
    timeout => 0,
    require => Package['libmysqlclient-dev']
  } ->
  exec { 'db-schema':
    command => 'rake db:schema:load > /out/logdbschema.log 2>&1',
    timeout => 0
  } ->
  exec { 'db-migrate':
    command => 'rake db:migrate > /out/logdbmigrate.log 2>&1',
    timeout => 0
  } ->
  exec { 'db-seed':
    command => 'rake db:seed > /out/logdbseed.log 2>&1',
    timeout => 0
  } ->
  # puma setting
  file { '/var/run/puma':
    ensure            =>  directory,
    owner => 'root',
    mode => '0777'
  } ->
  file { '/home/modem/puma.sh':
    ensure => file,
    source => ['puppet:///modules/pm/scripts/puma.sh'],
    owner => 'modem',
    mode => '0700'
  } ->
  file { '/home/modem/ember.sh':
    ensure => file,
    source => ['puppet:///modules/pm/scripts/ember.sh'],
    owner => 'modem',
    mode => '0700'
  } ->
  # Nginx settings
  file { '/var/opt/gitlab/nginx/etc/os-http.conf':
    ensure =>  file,
    source => ['puppet:///modules/pm/nginx/os-http.conf'], 
    owner => 'root'
  } ->
  file { '/var/opt/gitlab/nginx/etc/os-doc.conf':
    ensure =>  file,
    source => ['puppet:///modules/pm/nginx/os-doc.conf'], 
    owner => 'root'
  } ->
  file_line { 'os-http':
    path => '/var/opt/gitlab/nginx/etc/nginx.conf',
    line => 'include /var/opt/gitlab/nginx/etc/os-http.conf;',
    after => 'include /var/opt/gitlab/nginx/etc/gitlab-http.conf;'
  } ->
  file_line { 'os-doc':
    path => '/var/opt/gitlab/nginx/etc/nginx.conf',
    line => 'include /var/opt/gitlab/nginx/etc/os-doc.conf;',
    after => 'include /var/opt/gitlab/nginx/etc/gitlab-http.conf;'
  } ->
  exec { 'restart_nginx2':
    command => '/opt/gitlab/embedded/sbin/nginx -c /var/opt/gitlab/nginx/etc/nginx.conf -s reload',
   user => 'root'
  }
  #exec { 'restart_nginx2':
  #  command => '/usr/bin/service nginx restart',
  #  user => 'root'
  #}
  ->
  # restart dnsmasq script
  file { '/root/rdnsmasq.sh':
    ensure => 'file',
    content => '#!/bin/bash
    hostsmin=$(find /etc/hosts.mvmc -mmin -1)
    [[ -n $hostsmin ]] && /etc/init.d/dnsmasq restart',
    owner => 'root',
    mode => '0700'
  }

  # nodejs and ember_build prerequisites
  class { 'nodejs':
    manage_package_repo       => false,
    nodejs_dev_package_ensure => 'present',
    npm_package_ensure        => 'present',
  }
  ->
  file { '/usr/bin/node':
    ensure   => 'link',
    target => '/usr/bin/nodejs',
  }
  ->
  package { 'fsmonitor':
    ensure   => present,
    provider => 'npm',
  }
  ->
  package { 'ember-tools':
    ensure   => present,
    provider => 'npm',
  }
}
