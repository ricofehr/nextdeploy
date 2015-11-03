# == Class: pm::http
#
# Install apache / php with help of official modules
#
#
# === Authors
#
# Eric Fehr <eric.fehr@publicis-modem.fr>
#
class pm::http {
  # apache setting
  class { '::apache':
    default_mods        => false,
    default_vhost => false,
    mpm_module => 'prefork',
    service_ensure => true,
    user => 'modem',
    manage_user => false,
    logroot_mode => '0775'
  }

  file { '/etc/apache2/mime.types':
   ensure => 'link',
   target => '/etc/mime.types',
  }

  # enable apache modules
  apache::mod { 'rewrite': }
  apache::mod { 'actions': }
  apache::mod { 'auth_basic': }
  apache::mod { 'autoindex': }
  apache::mod { 'deflate': }
  apache::mod { 'env': }
  apache::mod { 'expires': }
  apache::mod { 'headers': }
  apache::mod { 'setenvif': }
  apache::mod { 'status': }
  apache::mod { 'mpm_prefork': }
  apache::mod { 'access_compat': }
  apache::mod { 'authn_core': }

  # avoid issue when restart apache2.4
  file { '/etc/apache2/conf.d/tt.conf':
    content => ''
  }

  class {'::apache::mod::php':}

  php::ini { '/etc/php5/apache2/php.ini':
    display_errors => 'Off',
    memory_limit   => '1024M',
    max_execution_time => '0',
    date_timezone => 'Europe/Paris',
    session_cookie_httponly => '1',
    session_save_path => '/tmp',
    post_max_size => '150M',
    upload_max_filesize => '150M',
    error_reporting => "E_ALL & ~E_DEPRECATED & ~E_NOTICE"
  }

  php::module { [ 'mysql', 'redis', 'memcached', 'gd', 'curl', 'intl', 'mcrypt' ]: }
}