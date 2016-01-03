# == Class: pm::ftp
#
# Install vsftpd with help of this module
#
#
# === Authors
#
# Eric Fehr <ricofehr@nextdeploy.io>
#
class pm::ftp {
  Exec {
      path => '/usr/bin:/usr/sbin:/bin:/sbin',
      unless => 'test -f /root/.vsftpdinstall'
  }

  package { ['libpam-pwdfile', 'apache2-utils']:
    ensure => installed,
    require => Exec['apt-update']
  } ->
  class { '::vsftpd':}
  ->
  file { '/etc/pam.d/vsftpd':
    content => 'auth required pam_pwdfile.so pwdfile /etc/ftpd.passwd
account required pam_permit.so',
    owner => 'root',
    group => 'root'
  }
  ->
  file { '/usr/local/bin/nextdeploy-addftp':
    source => 'puppet:///modules/pm/vsftpd/nextdeploy-addftp',
    owner => 'root',
    group => 'root',
    mode => '0700'
  }
  ->
  file { '/usr/local/bin/nextdeploy-rmftp':
    source => 'puppet:///modules/pm/vsftpd/nextdeploy-rmftp',
    owner => 'root',
    group => 'root',
    mode => '0700'
  }
  ->
  exec { 'createftpdpasswd':
    command => 'touch /etc/ftpd.passwd'
  }
  ->
  exec { 'restartftpd':
    command => 'service vsftpd restart'
  }
  ->
  exec { 'touchftpd':
    command => 'touch /root/.vsftpdinstall'
  }
}