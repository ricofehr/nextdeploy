# == Class: pm::gitlab7
#
# Install gitlab with help of gitlab module and apply some custom settings
#
#
# === Authors
#
# Eric Fehr <eric.fehr@publicis-modem.fr>
#
class pm::gitlab7 {
  Exec {
      path => '/usr/bin:/usr/sbin:/bin:/sbin',
      timeout => 0,
      unless => 'test -f /home/modem/.gitlabconfig'
  }

  $server_name = hiera('global::gitlabns', 'gitlab.local')

  # prepare folders for git-data and backups
  file { '/home/git-data':
    ensure => directory,
    owner => 'git'
  } ->
  file { '/home/gitlab-backups':
    ensure => directory,
    owner => 'git'
  } ->
  class { 'gitlab': }
  ->
  exec { 'gitlab_reconfigure_fixweirdbug':
    command     => '/usr/bin/gitlab-ctl reconfigure',
    logoutput   => true,
    tries       => 5,
    require => Exec['gitlab_reconfigure']
  } ->
  file_line { 'gitlab_servername':
    path => '/var/opt/gitlab/nginx/conf/gitlab-http.conf',
    line => "server_name ${server_name};",
    match => '.*server_name.*'
  } ->
  exec { 'restart_nginx':
    command => '/opt/gitlab/embedded/sbin/nginx -c /var/opt/gitlab/nginx/conf/nginx.conf -p /var/opt/gitlab/nginx/ -s reload',
    user => 'root'
  } ->
  exec { 'touch_gitlabconfig':
    command => 'touch /home/modem/.gitlabconfig',
    user => 'modem'
  }
}
