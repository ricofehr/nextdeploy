# == Class: pm::nodejs
#
# Install nodejs / npm
#
#
# === Authors
#
# Eric Fehr <ricofehr@nextdeploy.io>
#
class pm::nodejs {
Exec {
    path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin", "/opt/bin" ]
  }

  # nodejs and ember_build prerequisites
  class { '::nodejs':
    repo_url_suffix => '4.x',
  }
  ->
  file { '/usr/bin/node':
    ensure   => 'link',
    target => '/usr/bin/nodejs',
  }
  ->
  package { ['pm2', 'grunt-cli', 'grunt', 'bower', 'gulp']:
    ensure   => present,
    provider => 'npm',
  }

  exec { 'nodejs-aptupdate':
    command => "/usr/bin/apt-get update",
    timeout => 1800,
    user => 'root',
    creates => '/usr/bin/node'
  }

  # ensure that apt-update is running before install nodejs package
  Apt::Source <| |> ~> Exec['nodejs-aptupdate'] -> Package['nodejs']
}
