# == Class: pm::puppet
#
# Install puppet-master with custom settings
#
#
# === Authors
#
# Eric Fehr <eric.fehr@publicis-modem.fr>
#
class pm::puppet {
  Exec { path => [ "/bin/", "/sbin/", "/usr/bin/", "/usr/sbin/", "/usr/local/bin", "/opt/bin" ],
         user => 'root',
         unless => 'test -f /home/modem/.puppetinstall'
  }

  exec { 'getaptsource':
    command => 'wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb'
  } ->
  exec { 'installaptsource':
    command => 'dpkg -i puppetlabs-release-trusty.deb'
  } ->
  exec { 'aptupdate':
    command => 'apt-get update',
    timeout => 0
  } ->
  exec { 'installpuppet':
    command => 'apt-get install -y puppetmaster'
  } ->
  exec { 'stoppuppet':
    command => 'service puppetmaster stop',
  } ->
  exec { 'rmdirmodules':
    command => 'rm -rf /etc/puppet/modules',
  } ->
  file { '/etc/puppet/modules':
    ensure => link,
    target => '/puppet'
  } ->
  file { '/etc/puppet/modules/pm/files':
    ensure => directory
  } ->
  file { '/etc/puppet/modules/pm/files/sshkeys':
    ensure => link,
    target => '/ror/sshkeys'
  } ->
  file { '/etc/puppet/puppet.conf':
    ensure => file,
    source => [ "puppet:///modules/pm/puppet/puppet.conf_${clientcert}",
                "puppet:///modules/pm/puppet/puppet.conf" ],
    owner => 'puppet',
    group => 'puppet'
  } ->
  file { '/etc/puppet/manifests/site.pp':
    ensure => file,
    source => [ "puppet:///modules/pm/puppet/site.pp" ],
    owner => 'puppet'
  } ->
  file { '/etc/hiera.yaml':
    ensure => file,
    source => [ "puppet:///modules/pm/puppet/hiera.yaml" ],
    owner => 'root',
    group => 'root'
  } ->
  exec { 'chownpuppet':
    command => 'chown -R modem:modem /var/lib/puppet'
  } ->
  exec { 'chownpuppet2':
    command => 'chown -R root:root /var/lib/puppet/lib'
  } ->
  exec { 'startpuppet':
    command => 'service puppetmaster start'
  } ->
  exec { 'touchpuppetinstall':
    command => 'touch /home/modem/.puppetinstall',
    user => 'modem'
  }
}
