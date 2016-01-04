# == Class: pm::fw
#
# Install firewall script for current node
#
#
# === Authors
#
# Eric Fehr <ricofehr@nextdeploy.io>
#
class pm::fw {
  file { '/etc/init.d/firewall':
    owner => 'root',
    mode => '700',
    source => [ "puppet:///modules/pm/fw/fw_${clientcert}" ],
    group => 'root'
  } ->
  file_line { 'fwrclocal':
    path => '/etc/rc.local',
    line => '/etc/init.d/firewall start; exit 0',
    match => 'exit 0$',
    multiple => false
  } ->
  exec { 'fw_exec':
    command => '/etc/init.d/firewall start',
    path => '/usr/bin:/usr/sbin:/bin:/sbin',
    unless => '/sbin/iptables-save | grep "dport 8140"'
  }
}
