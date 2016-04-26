# == Class: pm::sql
#
# Install mysql with help of official module
#
#
# === Authors
#
# Eric Fehr <ricofehr@nextdeploy.io>
#
class pm::sql {
  class { '::mysql::server':
   notify => Exec['restart-mysql'],
  }

  exec {'restart-mysql':
    command => 'service mysql restart',
    path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin", "/opt/bin" ],
    unless => 'test -f /root/.sqlrestart'
  } ->

  exec { 'touchsqlrestart':
    path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin", "/opt/bin" ],
    command => 'touch /root/.sqlrestart',
    unless => 'test -f /root/.sqlrestart'
  } ->

  class { 'pm::monitor::collect::mysql': }

  create_resources ('mysql::db', hiera('mysql_db', []))
}
