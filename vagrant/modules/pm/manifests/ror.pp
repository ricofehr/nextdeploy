# == Class: pm::ror
#
# Install rvm and some gems with help of official module
#
#
# === Authors
#
# Eric Fehr <ricofehr@nextdeploy.io>
#
class pm::ror {
  class{ 'rvm::rvmrc':
    max_time_flag => 360,
    before  => Class['rvm'],
  }

  class { 'rvm': }

  $gems = hiera('rvm::gem', [])
  create_resources('rvm_gem', $gems, { require => Exec['system-rvm'] })

  package { ['libmysqlclient-dev']: ensure => installed }

  class { '::memcached':
    max_memory => '2048'
  }

  class { 'pm::monitor::collect::memcached': }

  Exec['installcurl'] -> Exec['system-rvm']
}
