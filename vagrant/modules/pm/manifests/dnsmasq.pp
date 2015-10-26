# == Class: pm::dnsmasq
#
# Install dnsmaq with some customs settings file
#
#
# === Authors
#
# Eric Fehr <eric.fehr@publicis-modem.fr>
#
class pm::dnsmasq {
  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin", "/opt/bin" ],
      unless => 'test -f /root/.dnsmasqconfig'
  }

  package { [
          'dnsmasq',
          ]:
          ensure => installed
          } ->

  file { '/etc/default/dnsmasq':
    ensure => file,
    source => [ "puppet:///modules/pm/dnsmasq/dnsmasq_default.conf" ],
    owner => 'root',
    group => 'root'
  } ->

  file { '/etc/dnsmasq.conf':
    ensure => file,
    source => [ "puppet:///modules/pm/dnsmasq/dnsmasq.conf" ],
    owner => 'root',
    group => 'root'
  } ->

  exec { 'restart-dnsmasq':
    command => 'service dnsmasq restart'
  } ->

  exec { 'touchhosts':
    command => 'touch /etc/hosts.mvmc'
  } ->

  exec { 'chmodhosts':
    command => 'chmod 777 /etc/hosts.mvmc'
  }  ->

  exec { 'localhostresolvconf':
    command => 'sed -i "s;nameserver .*$;nameserver 127.0.0.1;" /etc/resolv.conf'
  } ->

  exec { 'touch_dnsmasqconfig':
    command => 'touch /root/.dnsmasqconfig',
  }
}
