# == Class: pm::hosts
#
# Install a custom hosts file
#
#
# === Authors
#
# Eric Fehr <eric.fehr@publicis-modem.fr>
#
class pm::hosts {
  file { '/etc/hosts':
    ensure => file,
    source => [ 
      "puppet:///modules/pm/hosts/hosts.${clientcert}",
      "puppet:///modules/pm/hosts/hosts"
      ]
  }
}
