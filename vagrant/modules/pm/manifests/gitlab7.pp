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
  $server_name = hiera('gitlab::server_name', 'gitlab.local')

  class { 'gitlab': }
  ->
  file_line { 'gitlab_servername':
    path => '/var/opt/gitlab/nginx/etc/gitlab-http.conf',
    line => "server_name ${server_name};",
    match => '.*server_name.*'
  } ->
  exec { 'restart_nginx':
    command => '/opt/gitlab/embedded/sbin/nginx -c /var/opt/gitlab/nginx/etc/nginx.conf -s reload',
    user => 'root'
  }
}
