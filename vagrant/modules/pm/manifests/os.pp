
# == Class: pm::os::memcached
#
# Install memcached (on controller node) with help of official module
#
#
# === Authors
#
# Eric Fehr <ricofehr@nextdeploy.io>
#
class pm::os::memcached_c {
  class { '::memcached': }
}


# == Class: pm::os::keystone
#
# Install keystone (on controller node) with help of official module
#
#
# === Authors
#
# Eric Fehr <ricofehr@nextdeploy.io>
#
class pm::os::keystone {

  class { '::keystone':
    require => [ Class ['pm::sql'], Class ['pm::rabbit'], File['/etc/hosts'] ],
  }

  # Installs the service user endpoint.
  class { 'keystone::endpoint': }

  create_resources('keystone_tenant', hiera('keystone_tenant', []))
  create_resources('keystone_user', hiera('keystone_user', []))
  create_resources('keystone_role', hiera('keystone_role', []))
  create_resources('keystone_user_role', hiera('keystone_user_role', []))
  create_resources('keystone_service', hiera('keystone_service', []))
  create_resources('keystone_endpoint', hiera('keystone_endpoint', []))
}


# == Class: pm::os::nv_c
#
# Install nova-api (on controller node) with help of official module
#
#
# === Authors
#
# Eric Fehr <ricofehr@nextdeploy.io>
#
class pm::os::nv_c {

  class { '::nova':
    require => [ Class['pm::os::memcached_c'], Class ['pm::sql'], Class ['pm::rabbit'], File['/etc/hosts'] ],
  }

  class { '::nova::api': }

  class { '::nova::network::neutron':
    require => [ File['/etc/hosts'] ],
  }

  class { [
    'nova::scheduler',
    'nova::objectstore',
    'nova::cert',
    'nova::consoleauth',
    'nova::conductor'
  ]:
    enabled => true,
  }
}


# == Class: pm::os::nv
#
# Install nova on compute side with help of official module
#
#
# === Authors
#
# Eric Fehr <ricofehr@nextdeploy.io>
#
class pm::os::nv {
  Exec {
      path => '/usr/bin:/usr/sbin:/bin:/sbin',
      user => 'root'
  }

  ::sysctl::value { 'net.ipv4.conf.all.rp_filter':
    value     => '0',
  }

  ::sysctl::value { 'net.ipv4.conf.default.rp_filter':
    value     => '0',
  }

  class { '::keystone':
    require => [ File['/etc/hosts'] ],
  }

  # enable the neutron service
  class { '::neutron':
    require => [ File['/etc/hosts'] ],
  }

  class { '::neutron::server': }

  class { '::neutron::server::notifications':
    require => [ File['/etc/hosts'] ],
  }

  class { '::neutron::agents::ml2::ovs': }

  class  { '::neutron::plugins::ml2': }

  class { '::nova':
    require => [ File['/etc/hosts'] ],
  }

  nova_config { 'DEFAULT/default_floating_pool': value => 'public' }
  nova_config { 'DEFAULT/resume_guests_state_on_host_boot': value => true }

  class { '::nova::compute':
    require => [ File['/etc/hosts'] ],
  }

  class { '::nova::compute::libvirt': }

  file { '/etc/libvirt/qemu.conf':
    ensure => present,
    mode   => '0644',
    source => [ "puppet:///modules/pm/qemu/qemu.conf" ],
    notify => Service['libvirt'],
    owner => 'root'
  }

  Package['libvirt'] -> File['/etc/libvirt/qemu.conf']

  class { '::nova::compute::neutron': }

  class { '::nova::network::neutron':
    require => [ File['/etc/hosts'] ],
  }
}


# == Class: pm::os::nv_postinstall
#
# Some commands who must be executed at the end of compute node creation
#
#
# === Authors
#
# Eric Fehr <ricofehr@nextdeploy.io>
#
class pm::os::nv_postinstall {
  Exec {
      path => '/usr/bin:/usr/sbin:/bin:/sbin',
      user => 'root',
      unless => 'test -f /home/modem/.novapostinstall'
  }

  # move nova folder into home filesystem (ensure that we have large disk space)
  exec { 'mknova':
    command => 'mkdir -p /home/nova'
  } ->
  exec { 'movenova':
    command => 'mv /var/lib/nova/* /home/nova/'
  } ->
  exec { 'rmdirnova':
    command => 'rmdir /var/lib/nova'
  } ->
  file { '/var/lib/nova':
    ensure => 'link',
    target => '/home/nova'
  } ->
  exec { 'restartcompute':
    command => 'service nova-compute restart'
  } ->
  exec { 'touchnovapostinstall':
    command => 'touch /home/modem/.novapostinstall',
    user => 'modem'
  }
}

# == Class: pm::os::nv0_postinstall
#
# Some commands who must be executed at the end of main and first compute node creation
#
#
# === Authors
#
# Eric Fehr <ricofehr@nextdeploy.io>
#
class pm::os::nv0_postinstall {
  Exec {
      path => '/usr/bin:/usr/sbin:/bin:/sbin',
      user => 'modem',
      unless => 'test -f /home/modem/.novapostinstall0'
  }

  # post install stuff: flavors and quotas
  exec { 'nova-secgroup-rule22':
    command => 'nova --os-username user --os-password wordpass --os-tenant-name tenant0 --os-auth-url http://controller-m:35357/v2.0 secgroup-add-rule default tcp 22 22 0.0.0.0/0',
  } ->
  exec { 'nova-secgroup-rule80':
    command => 'nova --os-username user --os-password wordpass --os-tenant-name tenant0 --os-auth-url http://controller-m:35357/v2.0 secgroup-add-rule default tcp 80 80 0.0.0.0/0',
  } ->
  exec { 'nova-secgroup-ruleicmp':
    command => 'nova --os-username user --os-password wordpass --os-tenant-name tenant0 --os-auth-url http://controller-m:35357/v2.0 secgroup-add-rule default icmp -1 -1 0.0.0.0/0',
  } ->
  exec { 'nova-delete-tiny':
    command => 'nova --os-username nova --os-password osnova --os-tenant-name services --os-auth-url http://controller-m:35357/v2.0 flavor-delete 1',
  } ->
  exec { 'nova-recreate-tiny':
    command => 'nova --os-username nova --os-password osnova --os-tenant-name services --os-auth-url http://controller-m:35357/v2.0 flavor-create m1.tiny 1 512 15 1',
  }
  exec { 'nova-delete-small':
    command => 'nova --os-username nova --os-password osnova --os-tenant-name services --os-auth-url http://controller-m:35357/v2.0 flavor-delete 2',
  } ->
  exec { 'nova-recreate-small':
    command => 'nova --os-username nova --os-password osnova --os-tenant-name services --os-auth-url http://controller-m:35357/v2.0 flavor-create m1.small 2 1024 15 2',
  } ->
  exec { 'nova-quota-instances':
    command => 'nova --os-username nova --os-password osnova --os-tenant-name services --os-auth-url http://controller-m:35357/v2.0 quota-class-update --instances 170 default',
  } ->
  exec { 'nova-quota-keypairs':
    command => 'nova --os-username nova --os-password osnova --os-tenant-name services --os-auth-url http://controller-m:35357/v2.0 quota-class-update --key-pairs 1700 default',
  } ->
  exec { 'nova-quota-floatingips':
    command => 'nova --os-username nova --os-password osnova --os-tenant-name services --os-auth-url http://controller-m:35357/v2.0 quota-class-update --floating-ips 170 default',
  } ->
  exec { 'nova-quota-cores':
    command => 'nova --os-username nova --os-password osnova --os-tenant-name services --os-auth-url http://controller-m:35357/v2.0 quota-class-update --cores 416 default',
  } ->
  exec { 'nova-quota-ram':
    command => 'nova --os-username nova --os-password osnova --os-tenant-name services --os-auth-url http://controller-m:35357/v2.0 quota-class-update --ram 122880 default',
  } ->
  exec { 'nova-quota-meta':
    command => 'nova --os-username nova --os-password osnova --os-tenant-name services --os-auth-url http://controller-m:35357/v2.0 quota-class-update --metadata-items 1280 default',
  } ->
  exec { 'nova-quota-servergroups':
    command => 'nova --os-username nova --os-password osnova --os-tenant-name services --os-auth-url http://controller-m:35357/v2.0 quota-class-update --server-groups 170 default',
  } ->
  exec { 'nova-quota-servergroupmembers':
    command => 'nova --os-username nova --os-password osnova --os-tenant-name services --os-auth-url http://controller-m:35357/v2.0 quota-class-update --server-group-members 170 default',
  } ->
  exec { 'cinder-quota-gb':
    command => 'cinder --os-username cinder --os-password oscinder --os-tenant-name services --os-auth-url http://controller-m:35357/v2.0 quota-update --gigabytes 4000 default',
  } ->
  exec { 'cinder-quota-volumes':
    command => 'cinder --os-username cinder --os-password oscinder --os-tenant-name services --os-auth-url http://controller-m:35357/v2.0 quota-update --volumes 170 default',
  } ->
  exec { 'cinder-quota-snapshots':
    command => 'cinder --os-username cinder --os-password oscinder --os-tenant-name services --os-auth-url http://controller-m:35357/v2.0 quota-update --snapshots 170 default',
  } ->
  exec { 'neutron-quota-port':
    command => 'neutron --os-username neutron --os-password osneutron --os-tenant-name services --os-auth-url http://controller-m:35357/v2.0 quota-update --port 170 --tenant-id "$(openstack --os-username neutron --os-password osneutron --os-tenant-name services --os-auth-url http://controller-m:35357/v2.0 project show -f value tenant0 -c id | tr -d "\n")"',
  } ->
  exec { 'neutron-quota-floatingip':
    command => 'neutron --os-username neutron --os-password osneutron --os-tenant-name services --os-auth-url http://controller-m:35357/v2.0 quota-update --floatingip 170 --tenant-id "$(openstack --os-username neutron --os-password osneutron --os-tenant-name services --os-auth-url http://controller-m:35357/v2.0 project show -f value tenant0 -c id | tr -d "\n")"',
  } ->
  exec { 'touchnovapostinstall0':
    command => 'touch /home/modem/.novapostinstall0',
  }
}


# == Class: pm::os::gl
#
# Install glance with help of official module
#
#
# === Authors
#
# Eric Fehr <ricofehr@nextdeploy.io>
#
class pm::os::gl {
  Exec {
      path => '/usr/bin:/usr/sbin:/bin:/sbin',
      user => 'modem',
      unless => 'test -f /home/modem/.glancesleep'
  }

  # add a sleep to avoid a bug during an install of glance into virtualbox
  class { '::glance::api':
    require => [ File['/etc/hosts'] ],
  } ->
  exec { 'waitglance':
    command => '/bin/sleep 60'
  }

  # add a sleep to avoid a bug during an install of glance into virtualbox
  class { '::glance::registry':
    require => [ File['/etc/hosts'] ],
  } ->
  exec { 'waitglance2':
    command => '/bin/sleep 60'
  }

  # make a lock to avoid other sleep execution
  exec { 'touchglancesleep':
    command => 'touch /home/modem/.glancesleep',
    require => [ Exec['waitglance'], Exec['waitglance'] ]
  }

  class { '::glance::backend::file':
    require => [ File['/etc/hosts'] ],
  }

  class { '::glance::notify::rabbitmq':
    require => [ File['/etc/hosts'] ],
  }

  create_resources('glance_image', hiera('glance_image', []), { require => File['/etc/hosts'] })
}


# == Class: pm::os::nt_c
#
# Install neutron-server on controller side with help of official module
#
#
# === Authors
#
# Eric Fehr <ricofehr@nextdeploy.io>
#
class pm::os::nt_c {

  # enable the neutron service
  class { '::neutron':
    require => [ Class ['pm::sql'], Class ['pm::rabbit'], File['/etc/hosts'] ],
  }

  # configure authentication
  class { 'neutron::server':
    require => [ Class ['pm::sql'], Class ['pm::rabbit'], File['/etc/hosts'] ],
  }

  class { '::neutron::server::notifications':
    require => [ File['/etc/hosts'] ],
  }

  class { '::neutron::agents::ml2::ovs':
    require => [ File['/etc/hosts'] ],
  }

  class  { '::neutron::plugins::ml2': }
}


# == Class: pm::os::nt
#
# Install neutron node with help of official module
#
#
# === Authors
#
# Eric Fehr <ricofehr@nextdeploy.io>
#
class pm::os::nt {
  Exec {
      path => '/usr/bin:/usr/sbin:/bin:/sbin',
      timeout => 0,
      unless => 'test -f /home/modem/.neutronconfig'
  }

  # some hiera variable
  $ext_dev = hiera('externaldev', 'eth0')
  $gateway_ip = hiera('gateway_ip', '')
  $masquerade_dev = hiera('masqdev', 'eth0')

  ::sysctl::value { 'net.ipv4.ip_forward':
    value     => '1',
  }

  ::sysctl::value { 'net.ipv4.conf.all.rp_filter':
    value     => '0',
  }

  ::sysctl::value { 'net.ipv4.conf.default.rp_filter':
    value     => '0',
  }

  class { '::keystone':
    require => [ File['/etc/hosts'] ],
  }

  # enable the neutron service
  class { '::neutron':
    require => [ File['/etc/hosts'] ],
  }

  # configure authentication
  class { 'neutron::server':
    require => [ File['/etc/hosts'] ],
  }

  class { '::neutron::server::notifications':
    require => [ File['/etc/hosts'] ],
  }

  class { '::neutron::agents::ml2::ovs': }

  class  { '::neutron::plugins::ml2': }

  ## Router service installation
  class { '::neutron::agents::l3': }

  class { '::neutron::agents::dhcp': }

  class { '::neutron::agents::metadata':
    require => [ File['/etc/hosts'] ],
  }

  class { '::neutron::agents::metering': }

  class { '::neutron::services::fwaas': }

  exec { 'gro-off':
    command => "ethtool -K ${ext_dev} gro off",
    path => '/usr/bin:/usr/sbin:/bin:/sbin',
  }

  create_resources('vs_bridge', hiera('vs_bridge', []))
  create_resources('vs_port', hiera('vs_port', []))

  exec { 'ifcfg':
    command => "ifconfig brex ${gateway_ip}",
    path => '/usr/bin:/usr/sbin:/bin:/sbin'
  } ->
  file { '/root/ethtobr.sh':
    owner => 'root',
    mode => '700',
    source => [ "puppet:///modules/pm/scripts/ethtobr.sh" ]
  } ->
  exec { 'ethtobr':
    command => "/root/./ethtobr.sh ${ext_dev}"
  } ->
  exec { 'ipt':
    command => "iptables -t nat -A POSTROUTING -o ${masquerade_dev} -j MASQUERADE",
  } ->
  file { '/etc/rc.local':
    content => "ifconfig brex ${gateway_ip}
/root/./ethtobr.sh ${ext_dev}
iptables -t nat -A POSTROUTING -o ${masquerade_dev} -j MASQUERADE
exit 0"
  } ->
  exec { 'touchneutronconfig':
    command => 'touch /home/modem/.neutronconfig',
  }
}


# == Class: pm::os::nt_postinstall
#
# Some commands (networks, subnets and router creations) who must be executed at the end of neutron node creation
#
#
# === Authors
#
# Eric Fehr <ricofehr@nextdeploy.io>
#
class pm::os::nt_postinstall {

  create_resources('neutron_network', hiera('neutron_network', []))
  create_resources('neutron_subnet', hiera('neutron_subnet', []))
  create_resources('neutron_router', hiera('neutron_router', []))
  create_resources('neutron_router_interface', hiera('neutron_router_interface', []))
}


# == Class: pm::os::cder_c
#
# Install cinder-api on controller node with help of official module
#
#
# === Authors
#
# Eric Fehr <ricofehr@nextdeploy.io>
#
class pm::os::cder_c {

  class { 'cinder':
    require => [ Class ['pm::sql'], Class ['pm::rabbit'], File['/etc/hosts'] ],
  }

  class { '::cinder::glance': }

  class { 'cinder::api':
    require => [ File['/etc/hosts'] ],
  }

  class { 'cinder::scheduler': }
}


# == Class: pm::os::cder
#
# Install cinder on glance node with help of official module
#
#
# === Authors
#
# Eric Fehr <ricofehr@nextdeploy.io>
#
class pm::os::cder {

  class { '::keystone':
    require => [ File['/etc/hosts'] ],
  }

  class { '::cinder':
    require => [ File['/etc/hosts'] ],
  }

  class { '::cinder::glance':
    require => [ File['/etc/hosts'] ],
  }

  class { '::cinder::setup_test_volume': } ->

  class { '::cinder::volume': }

  class { '::cinder::volume::iscsi': }
}


# == Class: pm::os::hz
#
# Install horizon (openstack webui) on controller side with help of official module
#
#
# === Authors
#
# Eric Fehr <ricofehr@nextdeploy.io>
#
class pm::os::hz {
  class { '::horizon':
    require => [ Class ['pm::sql'], Class ['pm::rabbit'], File['/etc/hosts'] ],
  }
}
