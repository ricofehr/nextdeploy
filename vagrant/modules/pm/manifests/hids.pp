# == Class: pm::hids::server
#
# Install ossec server for store security alerts from remote vms and servers
#
#
# === Authors
#
# Eric Fehr <eric.fehr@publicis-modem.fr>
#
class pm::hids::server {
  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin", "/opt/bin" ] }

  $mailadmin = hiera('global::mailadmin', '')

  class { 'ossec::server':
    mailserver_ip => '127.0.0.1',
    ossec_active_response => false,
    ossec_emailto => "${mailadmin}"
  }

  ossec::addlog { 'varnishLogFile':
    logfile => '/var/log/varnish',
    logtype => 'apache'
  }

  ossec::addlog { 'mysqlLogFile':
    logfile => '/var/log/mysql',
    logtype => 'mysql_log'
  }

  exec { 'keyossec':
    command => 'openssl genrsa -out /var/ossec/etc/sslmanager.key 2048',
    unless => 'test -f /var/ossec/etc/sslmanager.key',
    require => Class['ossec::server']
  } ->

  exec { 'certossec':
    command => 'openssl req -new -x509 -key /var/ossec/etc/sslmanager.key -out /var/ossec/etc/sslmanager.cert -days 7300 -subj "/C=FR/ST=IDF/L=Paris/O=MyCompany/CN=ossec"',
    unless => 'test -f /var/ossec/etc/sslmanager.cert'
  } ->

  file { '/usr/bin/start-authd':
    content => '#!/bin/bash
nohup /var/ossec/bin/ossec-authd -p 1515 &',
    owner => 'root',
    group => 'root',
    mode => '0700'
  } ->

  exec { 'nohupauthd':
    command => 'nohup /var/ossec/bin/ossec-authd -p 1515 &',
    unless => 'test -f /root/.ossecinstall'
  } ->
  # client.keys invalid after install
  exec { 'touchclientkeys':
    command => 'rm -f /var/ossec/etc/client.keys',
    unless => 'test -f /root/.ossecinstall'
  } ->

  exec { 'touchossecinstall':
    command => 'touch /root/.ossecinstall',
    unless => 'test -f /root/.ossecinstall'
  } ->
  # remoted is down while there is no agent ...
  cron { 'remotedfix':
    command => '/bin/ps aux | /bin/grep ossec-remoted | /bin/grep -v grep || /etc/init.d/ossec restart',
    user => 'root',
    minute => '*',
    hour => '*'
  } ->
  # check authd
  cron { 'checkauthd':
    command => '/bin/ps aux | /bin/grep ossec-authd | /bin/grep -v grep || /usr/bin/./start-authd',
    user => 'root',
    minute => '*',
    hour => '*'
  }
}

# == Class: pm::hids::agent
#
# Install ossec agent for send security alerts
#
#
# === Authors
#
# Eric Fehr <eric.fehr@publicis-modem.fr>
#
class pm::hids::agent {
  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin", "/opt/bin" ] }
  
  $ossecip = hiera('global::ossecip', '')

  class { "ossec::client":
    ossec_server_ip => "${ossecip}",
    ossec_active_response => false,
  }
}


# == Class: pm::hids::webui
#
# Install webui for ossec
#
#
# === Authors
#
# Eric Fehr <eric.fehr@publicis-modem.fr>
#
class pm::hids::webui {
  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin", "/opt/bin" ] }

  $ossecuri = hiera('global::ossecuri', '')
  
  exec { 'wwwinossec': 
    command => 'usermod -G ossec www-data',
    unless => 'test -f /home/ossec-wui/index.php',
    require => Class['ossec::server']
  } ->

  class { 'pm::http': } ->

  file { '/home/ossec-wui':
    ensure => 'directory',
    owner => 'www-data',
    group => 'ossec'
  } ->

  apache::vhost { "${ossecuri}":
    servername      => "${ossecuri}",
    port            => 9081,
    docroot         => '/home/ossec-wui',
    error_log_file  => 'ossec_error.log',
    access_log_file => 'ossec_access.log',
    directories     => [
    {
       path            => '/home/ossec-wui',
       options         => [ 'None' ],
       allow_override  => [ 'None' ],
    }
    ]
  } ->

  exec { 'clonewebui':
    command => 'git clone https://github.com/ossec/ossec-wui.git /home/ossec-wui/',
    unless => 'test -f /home/ossec-wui/index.php',
    user => 'www-data',
    group => 'ossec',
    require => Package['git-core']
  }
}