# == Class: pm::phpcli
#
# Install php and drush command
#
#
# === Authors
#
# Eric Fehr <eric.fehr@publicis-modem.fr>
#
class pm::phpcli {
  Exec { 
    path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin", "/opt/bin" ], 
    unless => 'test -f /root/.installphpcli'
  }

  #list of pkgs
  package { [
        'php5-cli',
        'php5-common',
        'php5-curl',
        'php5-dev',
        'php5-gd',
        'php5-ldap',
        'php5-mcrypt',
        'php5-memcache',
        'php5-mysql',
        'php5-xmlrpc',
        'php-pear'
        ]:
        ensure => installed,
        require => Exec['apt-update']
  } ->

  php::ini { '/etc/php5/cli/php.ini':
    memory_limit   => '1024M',
    max_execution_time => '0',
    date_timezone => 'Europe/Paris'
  } ->

  exec {'pear-consoletable':
    command => 'pear install -f Console_Table'
  } ->

  exec { 'getdrush':
    command => 'wget https://github.com/drush-ops/drush/releases/download/8.0.0-rc4/drush.phar',
    creates => '/usr/local/bin/drush',
    cwd => '/tmp'
  } ->

  exec { 'coredrush':
    command => 'php drush.phar core-status',
    creates => '/usr/local/bin/drush',
    cwd => '/tmp'
  } ->  

  exec { 'chmodrush':
    command => 'chmod +x drush.phar',
    creates => '/usr/local/bin/drush',
    cwd => '/tmp'
  } ->   

  exec { 'mvdrush':
    command => 'mv drush.phar /usr/local/bin/drush',
    creates => '/usr/local/bin/drush',
    cwd => '/tmp'
  } ->

  exec {'wpcli-dl':
    command => 'curl -sL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /tmp/wp-cli.phar',
    require => Exec['installcurl'],
  } ->

  exec {'wpcli-chmod':
    command => 'chmod +x /tmp/wp-cli.phar'
  } ->

  exec {'wpcli-mv':
    command => 'mv -f /tmp/wp-cli.phar /usr/bin/wp'
  } ->

  exec { 'touchinstallphpcli':
    command => 'touch /root/.installphpcli'
  }
}
