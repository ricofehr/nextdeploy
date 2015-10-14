# == Class: pm::ftp
#
# Install vsftpd with help of thias module
#
#
# === Authors
#
# Eric Fehr <eric.fehr@publicis-modem.fr>
#
class pm::ftp {
  Exec {
      path => '/usr/bin:/usr/sbin:/bin:/sbin',
      unless => 'test -f /root/.vsftpdinstall'
  }

  package { ['libpam-pwdfile', 'apache2-utils']:
    ensure => installed
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
  file { '/usr/local/bin/mvmc-addftp':
    source => 'puppet:///modules/pm/vsftpd/mvmc-addftp',
    owner => 'root',
    group => 'root',
    mode => '0700'
  }
  ->
  file { '/usr/local/bin/mvmc-rmftp':
    source => 'puppet:///modules/pm/vsftpd/mvmc-rmftp',
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