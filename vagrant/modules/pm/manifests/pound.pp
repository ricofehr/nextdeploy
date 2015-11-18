# == Class: pm::pound
#
# Install pound for https use
#
#
# === Authors
#
# Eric Fehr <eric.fehr@publicis-modem.fr>
#
class pm::pound {
  Exec {
    path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin", "/opt/bin" ],
    user => 'root'
  }
  
  $https_address = hiera('global::httpsaddress', '0.0.0.0')
  $http_address = hiera('global::httpaddress', '127.0.0.1')
  $http_wildcard = hiera('global::httpwildcard', 'local')

  exec { 'certpound':
    command => 'openssl req -new -x509 -newkey rsa:2048 -keyout /etc/ssl/key.pem -nodes -out /etc/ssl/pound.cert -days 7300 -subj "/C=FR/ST=IDF/L=Paris/O=MyCompany/CN=*.${http_wildcard}"',
    creates => '/etc/ssl/pound.pem'
  } ->

  exec { 'certpem':
    command => 'cat /etc/ssl/key.pem /etc/ssl/pound.cert > /etc/ssl/pound.pem',
    creates => '/etc/ssl/pound.pem'
  } ->

  # pound service
  package { 'pound':
    ensure => present,
    install_options => [ '-y', '--force-yes' ]
  } ->

  file { '/etc/default/pound':
    ensure => file,
    source => ["puppet:///modules/pm/pound/pound_default"],
    owner => 'root',
    group => 'root',
    notify => Service['pound']
  } ->

  file { '/etc/pound/pound.cfg':
    ensure => file,
    source => ["puppet:///modules/pm/pound/pound.cfg_${clientcert}",
      'puppet:///modules/pm/pound/pound.cfg'],
    owner => 'root',
    group => 'root',
    notify => Service['pound']
  } ->

  exec { 'poundaddress':
    command => "/bin/sed -i 's;%%PUBLICADDRESS%%;${https_address};' /etc/pound/pound.cfg",
    onlyif => 'grep PUBLICADDRESS /etc/pound/pound.cfg',
    user => 'root',
    notify => Service['pound']
  } ->

  exec { 'poundhttpaddress':
    command => "/bin/sed -i 's;%%HTTPADDRESS%%;${http_address};' /etc/pound/pound.cfg",
    onlyif => 'grep HTTPADDRESS /etc/pound/pound.cfg',
    user => 'root',
    notify => Service['pound']
  } ->

  service { 'pound':
    ensure => running,
    enable => true,
  }  
}