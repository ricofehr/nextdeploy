# == Class: pm::varnish
#
# Install and configure varnish
#
#
# === Authors
#
# Eric Fehr <ricofehr@nextdeploy.io>
#
class pm::varnish {
  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin", "/opt/bin" ] }

  $v = hiera('varnish_version', '3')

  package { 'varnish':
    ensure => present,
  }
  ->
  file { '/lib/systemd/system/varnish.service':
    ensure => file,
    mode   => 644,
    source => "puppet:///modules/pm/varnish/varnish.service.${v}",
    owner => 'root',
    group => 'root'
  }
  ->
  file { '/etc/default/varnish':
    ensure => file,
    mode   => 644,
    source => ["puppet:///modules/pm/varnish/varnish_default.${v}"],
    owner => 'root',
    group => 'root'
  }
  ->
  file { '/etc/varnish/default.vcl':
    ensure => file,
    mode   => 644,
    source => [
      "puppet:///modules/pm/varnish/custom/default.vcl_${clientcert}",
      "puppet:///modules/pm/varnish/default.vcl.${v}"
    ],
    owner => 'root',
    group => 'root',
    notify => Service['varnish']
  } ->
  file { '/etc/varnish/auth.vcl':
    ensure => file,
    mode   => 644,
    source => [
      "puppet:///modules/pm/varnish/auth/auth.vcl_${fqdn}",
      "puppet:///modules/pm/varnish/auth.vcl"
    ],
    owner => 'root',
    group => 'root'
  } ->
  service { 'varnish':
    ensure     => running,
    enable     => true,
  }
  ->
  # ugly condition (check if varnish is listening on port 80)
  exec { 'systemctl-reload':
    command => 'systemctl daemon-reload',
    onlyif => 'test -f /lib/systemd/system/varnish.service && test -f /bin/systemctl',
    unless => 'ps aux | grep varnish | grep "a :80" | grep -v grep'
  }
  ->
  # ugly condition (check if varnish is listening on port 80)
  exec { 'restartvarnish':
    command => 'service varnish restart',
    unless => 'ps aux | grep varnish | grep "a :80" | grep -v grep',
  }

  file { '/etc/default/varnishncsa':
    ensure => file,
    mode   => 644,
    source => [
      "puppet:///modules/pm/varnish/varnishncsa_default",
    ]
  }
  ->
  service { 'varnishncsa':
    ensure     => running,
    enable     => true,
    subscribe  => File['/etc/default/varnishncsa'],
    require    => Package['varnish']
  }
  ->
  class { 'pm::monitor::collect::varnish': }

}
