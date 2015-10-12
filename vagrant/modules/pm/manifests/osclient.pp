# == Class: pm::osclient
#
# Install scripts who define environment variables for request openstack api with differents users
#
#
# === Authors
#
# Eric Fehr <eric.fehr@publicis-modem.fr>
#
class pm::osclient {
  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin", "/opt/bin" ] }

  class {'nova::client':}
  class {'neutron::client':}
  class {'glance::client':}
  class {'cinder::client':}

  file { '/root/admin-openrc.sh':
    ensure => file,
    source => [ "puppet:///modules/pm/osenv/admin-openrc.sh" ],
    require => [
      Class['nova::client'],
      Class['neutron::client'],
      Class['glance::client'],
      Class['cinder::client'],
    ]
  } ->

  file { '/root/user-openrc.sh':
    ensure => file,
    source => [ "puppet:///modules/pm/osenv/user-openrc.sh" ],
    owner => 'root'
  } ->

  file { '/root/nova-openrc.sh':
    ensure => file,
    source => [ "puppet:///modules/pm/osenv/nova-openrc.sh" ],
    owner => 'root'
  } ->

  file { '/root/neutron-openrc.sh':
    ensure => file,
    source => [ "puppet:///modules/pm/osenv/neutron-openrc.sh" ],
    owner => 'root'
  } ->

  file { '/root/glance-openrc.sh':
    ensure => file,
    source => [ "puppet:///modules/pm/osenv/glance-openrc.sh" ],
    owner => 'root'
  } ->

  file { '/root/cinder-openrc.sh':
    ensure => file,
    source => [ "puppet:///modules/pm/osenv/cinder-openrc.sh" ],
    owner => 'root'
  }

}