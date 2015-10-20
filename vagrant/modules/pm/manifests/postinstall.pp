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
    user => 'root',
    unless => 'test -f /home/modem/.installmvmc'
  } ->
  exec { 'copyserial':
    command => 'cp -f /etc/openvpn/mvmc/easy-rsa/keys/serial /ror/vpnkeys/serial',
    user => 'root',
    unless => 'test -f /home/modem/.installmvmc'
  } ->
  exec { 'copycakey':
    command => 'cp -f /etc/openvpn/mvmc/easy-rsa/keys/ca.key /ror/vpnkeys/ca.key',
    user => 'root',
    unless => 'test -f /home/modem/.installmvmc'
  } ->
  exec { 'copycacrt':
    command => 'cp -f /etc/openvpn/mvmc/easy-rsa/keys/ca.crt /ror/vpnkeys/ca.crt',
    user => 'root',
    unless => 'test -f /home/modem/.installmvmc'
  } ->
  exec { 'copywhichopenssl':
    command => 'cp -f /etc/openvpn/mvmc/easy-rsa/whichopensslcnf /ror/vpnkeys/bin/whichopensslcnf',
    user => 'root',
    unless => 'test -f /home/modem/.installmvmc'
  } ->
  exec { 'copyopenssl098':
    command => 'cp -f /etc/openvpn/mvmc/easy-rsa/openssl-0.9.8.cnf /ror/vpnkeys/bin/openssl-0.9.8.cnf',
    user => 'root',
    unless => 'test -f /home/modem/.installmvmc'
  } ->
  exec { 'copyopenssl100':
    command => 'cp -f /etc/openvpn/mvmc/easy-rsa/openssl-1.0.0.cnf /ror/vpnkeys/bin/openssl-1.0.0.cnf',
    user => 'root',
    unless => 'test -f /home/modem/.installmvmc'
  } ->
  exec { 'copyopenssl096':
    command => 'cp -f /etc/openvpn/mvmc/easy-rsa/openssl-0.9.6.cnf /ror/vpnkeys/bin/openssl-0.9.6.cnf',
    user => 'root',
    unless => 'test -f /home/modem/.installmvmc'
  } ->
  exec { 'copyopenssl':
    command => 'cp -f /etc/openvpn/mvmc/easy-rsa/openssl.cnf /ror/vpnkeys/bin/openssl.cnf',
    user => 'root',
    unless => 'test -f /home/modem/.installmvmc'
  } ->
  exec { 'copypkitool':
    command => 'cp -f /etc/openvpn/mvmc/easy-rsa/pkitool /ror/vpnkeys/bin/pkitool',
    user => 'root',
    unless => 'test -f /home/modem/.installmvmc'
  } ->
  exec { 'chownmodemvpnkeys':
    command => 'chown -R modem: /ror/vpnkeys',
    user => 'root',
    unless => 'test -f /home/modem/.installmvmc'
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
    user => 'root',
    unless => 'test -f /home/modem/.installmvmc'
  } ->
  # ensure that ror and out folders is on modem owner
  # temporary before git repo will be public
  exec { 'chownmodem':
    command => 'chown -R modem: /home/mvmc',
    onlyif => 'test -d /home/mvmc',
    user => 'root',
    unless => 'test -f /home/modem/.installmvmc'
  } ->
  # disable hostkey verification on mvmc
  file_line { 'disable_hostchecking_ssh':
    path => '/etc/ssh/ssh_config',
    line => 'StrictHostKeyChecking no'
  } ->
  # git config email
  exec { 'gitconfig1':
    command => 'git config --global user.email admin@example.com',
    unless => 'test -f /home/modem/.installmvmc'
  } ->
  # git config username
  exec { 'gitconfig2':
    command => 'git config --global user.name root',
    unless => 'test -f /home/modem/.installmvmc'
  } ->
  # prepare ror website
  exec { 'bundle-clean':
    command => 'rm -rf vendor/bundle/*',
    unless => 'test -f /home/modem/.installmvmc'
  } ->
  # clean sshkeys
  exec { 'sshkeys-clean':
    command => 'rm -f sshkeys/*',
    unless => 'test -f /home/modem/.installmvmc'
  } ->
  # clean privatetoken
  exec { 'token-clean':
    command => 'rm -f tmp/private_token',
    unless => 'test -f /home/modem/.installmvmc'
  } ->
  # install ruby bundles
  exec { 'bundle-ror':
    command => 'bundle install --path vendor/bundle > /out/logbundle.log 2>&1',
    timeout => 0,
    unless => 'test -f /home/modem/.installmvmc',
    require => [ Package['libmysqlclient-dev'], Class['rvm'], Class['memcached'] ]
  } ->
  # database installation
  exec { 'db-schema':
    command => 'rake db:schema:load > /out/logdbschema.log 2>&1',
    timeout => 0,
    unless => 'test -f /home/modem/.installmvmc'
  } ->
  exec { 'db-migrate':
    command => 'rake db:migrate > /out/logdbmigrate.log 2>&1',
    timeout => 0,
    unless => 'test -f /home/modem/.installmvmc'
  } ->
  exec { 'db-seed':
    command => 'rake db:seed > /out/logdbseed.log 2>&1',
    timeout => 0,
    unless => 'test -f /home/modem/.installmvmc',
    require => File['/bin/sh']
  } ->
  # puma setting
  file { '/var/run/puma':
    ensure =>  directory,
    owner => 'modem',
    mode => '0777'
  } ->
  file { '/home/modem/puma.sh':
    ensure => file,
    source => ["puppet:///modules/pm/scripts/puma.sh_${clientcert}",
      'puppet:///modules/pm/scripts/puma.sh'],
    owner => 'modem',
    mode => '0700',
    group => 'modem'
  } ->
  exec { 'pumaenv':
    command => "/bin/sed -i 's;%%RAILSENV%%;${railsenv};' /home/modem/puma.sh",
    onlyif => 'grep RAILSENV /home/modem/puma.sh', 
  } ->
  file { '/home/modem/ember.sh':
    ensure => file,
    source => ['puppet:///modules/pm/scripts/ember.sh'],
    owner => 'modem',
    mode => '0700',
    group => 'modem'
  } ->
  # generate doc
  exec { 'yardoc_ror':
    command => 'bundle exec yardoc lib/**/*.rb app/**/*.rb config/**/*.rb',
    timeout => 120,
    unless => 'test -f /home/modem/.installmvmc'
  } ->
  exec { 'gitlabusersetting':
    command => 'echo "UPDATE application_settings SET signup_enabled=\'f\',max_attachment_size=60, default_projects_limit=0;" | sudo -u gitlab-psql /opt/gitlab/embedded/bin/psql -h /var/opt/gitlab/postgresql -d gitlabhq_production',
    user => 'root',
    unless => 'test -f /home/modem/.installmvmc'
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
    mode => '0700',
    group => 'root'
  } ->
  # need sudo for manage ftp users
  file_line { 'sudo_rule':
    path => '/etc/sudoers',
    line => 'modem ALL=(root) NOPASSWD: /usr/local/bin/./mvmc-*',
  } ->
  exec { 'touchinstallmvmc':
    command => 'touch /home/modem/.installmvmc',
    unless => 'test -f /home/modem/.installmvmc'
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
