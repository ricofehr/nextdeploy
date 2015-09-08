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
  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin", "/opt/bin" ] }

  # apache setting
  class { '::apache':
    default_mods        => false,
    default_vhost => false,
    mpm_module => 'prefork',
    service_ensure => true
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
  #apache::mod { 'authz_core': }

  # avoid issue when restart apache2.4
  exec {'touch_confd':
    command => 'touch /etc/apache2/conf.d/tt.conf'
  }
  ->
  # alias for a disallow-all robots.txt
  file { '/var/www/robots.txt':
    owner => 'www-data',
    group => 'www-data',
    content => 'User-agent: *
Disallow: /'
  }

  $vhost_params = hiera("apache_vhost", [])
  create_resources("apache::vhost", $vhost_params, { require => Exec['touch_confd'], before => Service['varnish'] })

  $kvhost = keys($vhost_params)
  class {'::apache::mod::php':}

  php::ini { '/etc/php.ini':
    display_errors => 'Off',
    memory_limit   => '1024M',
    date_timezone => 'Europe/Paris',
  }

  php::ini { '/etc/php5/apache2/php.ini':
    display_errors => 'Off',
    memory_limit   => '1024M',
    date_timezone => 'Europe/Paris',
    session_cookie_httponly => '1',
    session_save_path => '/tmp',
    post_max_size => '50M',
    upload_max_filesize => '50M',
    error_reporting => "E_ALL & ~E_DEPRECATED & ~E_NOTICE"
  }

  php::ini { '/etc/php5/cli/php.ini':
    display_errors => 'Off',
    memory_limit   => '1024M',
    date_timezone => 'Europe/Paris',
  }

  class { 'php::cli':}
  ->
  package { [ 'php-pear', 'php5-dev']:
    ensure => installed,
  }

  #install mongo extension only if mongo is part of the project
  $is_mongo = hiera("is_mongo", "no")
  if $is_cron == "yes" {
    exec { "pecl-mongo":
      command => "/usr/bin/yes '' | /usr/bin/pecl install --force mongo-1.5.8",
      user => "root",
      environment => ["HOME=/root"],
      unless => '/usr/bin/test -f /etc/php5/apache2/conf.d/20-mongo.ini',
      require => [ Package['php-pear'], Package['php5-dev'] ]
    }
    ->
    exec { "mongo.ini":
      command => "/bin/echo extension=mongo.so > /etc/php5/apache2/conf.d/20-mongo.ini",
      user => "root",
      environment => ["HOME=/root"],
    }
    ->
    exec { "mongo.inicli":
      command => "/bin/echo extension=mongo.so > /etc/php5/cli/conf.d/20-mongo.ini",
      user => "root",
      environment => ["HOME=/root"],
    }
  }

  php::module { [ 'mysql', 'redis', 'memcached', 'gd', 'curl', 'intl', 'mcrypt' ]: }


  #php::module::ini { 'apc':
  #  settings => {
  #    'apc.enabled'      => '1',
  #    'apc.shm_segments' => '1',
  #    'apc.shm_size'     => '64M',
  #  }
  #}
}