# == Class: pm::fw
#
# Install firewall script for current node
#
#
# === Authors
#
# Eric Fehr <eric.fehr@publicis-modem.fr>
#
class pm::fw {
  file { '/etc/init.d/firewall':
    owner => 'root',
    mode => '700',
    source => [ "puppet:///modules/pm/fw/fw_${clientcert}" ]
  } ->
  file_line { 'fw':
    path => '/etc/rc.local',
    line => '/etc/init.d/firewall start; exit 0',
    match => 'exit 0$',
    multiple => false
  } ->
  exec { 'fw_exec':
    command => '/etc/init.d/firewall start',
    path => '/usr/bin:/usr/sbin:/bin:/sbin'
  }
}
