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
  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin", "/opt/bin" ] }

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
        ensure => installed
  } ->
  exec {'pear-consoletable':
    command => 'pear install -f Console_Table'
  } ->
  exec {'pear-drushchannel':
    command => 'pear channel-discover pear.drush.org',
    unless => 'pear list-channels | grep pear.drush.org'
  } ->
  exec {'drush-install':
    command => 'pear install -f drush/drush',
    onlyif => 'test ! -f /usr/bin/drush',
  } ->
  exec {'wpcli-dl':
    command => 'curl -sL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /tmp/wp-cli.phar'
  } ->
  exec {'wpcli-chmod':
    command => 'chmod +x /tmp/wp-cli.phar'
  } ->
  exec {'wpcli-mv':
    command => 'mv -f /tmp/wp-cli.phar /usr/bin/wp'
  }
}
