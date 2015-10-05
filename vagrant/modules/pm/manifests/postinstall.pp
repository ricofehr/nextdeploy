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
  $railsenv = hiera('global::railsenv', 'development')
  $mvmcuri = hiera('global::mvmcuri', 'mvmc.local')
  $mvmcsuf = hiera('global::mvmcsuf', 'os.mvmc')

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

  # enable ip forwarding
  sysctl::value { "net.ipv4.ip_forward": value => "1"}

  # prepare vpnkeys folder
  exec { 'copyindextxt':
    command => 'cp -f /etc/openvpn/mvmc/easy-rsa/keys/index.txt /ror/vpnkeys/index.txt',
    user => 'root'
  } ->
  exec { 'copyserial':
    command => 'cp -f /etc/openvpn/mvmc/easy-rsa/keys/serial /ror/vpnkeys/serial',
    user => 'root'
  } ->
  exec { 'copycakey':
    command => 'cp -f /etc/openvpn/mvmc/easy-rsa/keys/ca.key /ror/vpnkeys/ca.key',
    user => 'root'
  } ->
  exec { 'copycacrt':
    command => 'cp -f /etc/openvpn/mvmc/easy-rsa/keys/ca.crt /ror/vpnkeys/ca.crt',
    user => 'root'
  } ->
  exec { 'copywhichopenssl':
    command => 'cp -f /etc/openvpn/mvmc/easy-rsa/whichopensslcnf /ror/vpnkeys/bin/whichopensslcnf',
    user => 'root'
  } ->
  exec { 'copyopenssl098':
    command => 'cp -f /etc/openvpn/mvmc/easy-rsa/openssl-0.9.8.cnf /ror/vpnkeys/bin/openssl-0.9.8.cnf',
    user => 'root'
  } ->
  exec { 'copyopenssl100':
    command => 'cp -f /etc/openvpn/mvmc/easy-rsa/openssl-1.0.0.cnf /ror/vpnkeys/bin/openssl-1.0.0.cnf',
    user => 'root'
  } ->
  exec { 'copyopenssl096':
    command => 'cp -f /etc/openvpn/mvmc/easy-rsa/openssl-0.9.6.cnf /ror/vpnkeys/bin/openssl-0.9.6.cnf',
    user => 'root'
  } ->
  exec { 'copyopenssl':
    command => 'cp -f /etc/openvpn/mvmc/easy-rsa/openssl.cnf /ror/vpnkeys/bin/openssl.cnf',
    user => 'root'
  } ->
  exec { 'copypkitool':
    command => 'cp -f /etc/openvpn/mvmc/easy-rsa/pkitool /ror/vpnkeys/bin/pkitool',
    user => 'root'
  } ->
  exec { 'chownmodemvpnkeys':
    command => 'chown -R modem: /ror/vpnkeys',
    user => 'root'
  } ->
  # patch gitlab for auto-confirm users
  file { '/opt/gitlab/embedded/service/gitlab-rails/lib/api/users.rb':
    ensure => file,
    source => ['puppet:///modules/pm/gitlab/users.rb'],
    owner => 'modem',
    mode => '0664',
    require => Exec['gitlab_reconfigure']
  } ->
  # restart gitlab
  exec { 'restartgitalb':
    command => '/usr/bin/gitlab-ctl restart',
    user => 'root'
  } ->
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
    timeout => 0,
    require => Exec['bashdefaultshell']
  } ->
  # puma setting
  file { '/var/run/puma':
    ensure =>  directory,
    owner => 'root',
    mode => '0777'
  } ->
  file { '/home/modem/puma.sh':
    ensure => file,
    source => ['puppet:///modules/pm/scripts/puma.sh'],
    owner => 'modem',
    mode => '0700'
  } ->
  exec { 'pumaenv':
    command => "/bin/sed -i 's;%%RAILSENV%%;${railsenv};' /home/modem/puma.sh", 
  } ->
  file { '/home/modem/ember.sh':
    ensure => file,
    source => ['puppet:///modules/pm/scripts/ember.sh'],
    owner => 'modem',
    mode => '0700'
  } ->
  # generate doc
  exec { 'yardoc_ror':
    command => 'bundle exec yardoc lib/**/*.rb app/**/*.rb config/**/*.rb',
    timeout => 120
  } ->
  # Nginx settings
  file { '/var/opt/gitlab/nginx/conf/os-http.conf':
    ensure =>  file,
    source => ['puppet:///modules/pm/nginx/os-http.conf'],
    owner => 'root'
  } ->
  file { '/var/opt/gitlab/nginx/conf/os-doc.conf':
    ensure =>  file,
    source => ['puppet:///modules/pm/nginx/os-doc.conf'],
    owner => 'root'
  } ->
  exec { 'mvmcsuffix':
    command => "/bin/sed -i 's;%%MVMCSUF%%;${mvmcsuf};' /var/opt/gitlab/nginx/conf/os-http.conf",
    user => 'root'
  } ->
  exec { 'mvmcuri':
    command => "/bin/sed -i 's;%%MVMCURI%%;${mvmcuri};' /var/opt/gitlab/nginx/conf/os-http.conf",
    user => 'root'
  } ->
  exec { 'mvmcuri2':
    command => "/bin/sed -i 's;%%MVMCURI%%;${mvmcuri};' /var/opt/gitlab/nginx/conf/os-doc.conf",
    user => 'root'
  } ->
  file_line { 'os-http':
    path => '/var/opt/gitlab/nginx/conf/nginx.conf',
    line => 'include /var/opt/gitlab/nginx/conf/os-http.conf;',
    after => 'include /var/opt/gitlab/nginx/conf/gitlab-http.conf;'
  } ->
  file_line { 'os-doc':
    path => '/var/opt/gitlab/nginx/conf/nginx.conf',
    line => 'include /var/opt/gitlab/nginx/conf/os-doc.conf;',
    after => 'include /var/opt/gitlab/nginx/conf/gitlab-http.conf;'
  } ->
  file_line { 'servernamehash':
    path => '/var/opt/gitlab/nginx/conf/nginx.conf',
    line => 'server_names_hash_bucket_size 128;',
    after => 'include /var/opt/gitlab/nginx/conf/gitlab-http.conf;'
  } ->
  exec { 'restart_nginx2':
    command => '/opt/gitlab/embedded/sbin/nginx -c /var/opt/gitlab/nginx/conf/nginx.conf -p /var/opt/gitlab/nginx/ -s reload',
   user => 'root'
  } ->
  file { '/hiera':
    ensure => 'link',
    target => '/ror/hiera',
    owner => 'root',
  } ->
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
