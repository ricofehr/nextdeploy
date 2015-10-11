# == Class: pm::ror
#
# Install rvm and some gems with help of official module
#
#
# === Authors
#
# Eric Fehr <eric.fehr@publicis-modem.fr>
#
class pm::ror {
  class{ 'rvm::rvmrc':
    max_time_flag => 180,
    before  => Class['rvm'],
  }

  class { 'rvm': }
  $gems = hiera('rvm::gem', [])
  create_resources('rvm_gem', $gems)
  package { ['libmysqlclient-dev']: ensure => installed }
  class { '::memcached': }
}
