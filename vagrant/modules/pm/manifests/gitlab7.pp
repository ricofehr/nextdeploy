# == Class: pm::gitlab7
#
# Install gitlab with help of gitlab module and apply some custom settings
#
#
# === Authors
#
# Eric Fehr <ricofehr@nextdeploy.io>
#
class pm::gitlab7 {
  Exec {
      path => '/usr/bin:/usr/sbin:/bin:/sbin',
      timeout => 0,
      creates => '/root/.gitlabconfig'
  }

  $server_name = hiera('global::gitlabns', 'gitlab.local')

  class { 'gitlab':
    before => [ Class['::rvm'], Class['::memcached'], Class['::mysql::server'], Package['collectd'] ]
  }
  ->

  exec { 'gitlab_setup_loginpassword':
    command     => '/bin/echo yes | /usr/bin/gitlab-rake gitlab:setup',
    timeout     => 1800,
    environment => ['GITLAB_ROOT_PASSWORD=5iveL!fe', 'GITLAB_ROOT_EMAIL=admin@example.com'],
    require     => Exec['gitlab_reconfigure'],
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
    command => 'touch /root/.gitlabconfig',
  }
}
