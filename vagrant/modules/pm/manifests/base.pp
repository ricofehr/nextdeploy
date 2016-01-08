# == Class: pm::base::apt
#
# Ensure that we make apt-update before installing packages
#
#
# === Authors
#
# Eric Fehr <ricofehr@nextdeploy.io>
#
class pm::base::apt {
  Exec {
    path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin", "/opt/bin" ],
    unless => 'test -f /root/.baseapt'
  }

  class { '::apt': }

  # upgrade ubuntu with kilo repo
  exec { 'ubuntu-cloud-keyring':
    command => '/usr/bin/apt-get install --yes --force-yes ubuntu-cloud-keyring',
    environment => 'DEBIAN_FRONTEND=noninteractive'
  } ->
  file { '/etc/apt/sources.list.d/cloudarchive-kilo.list':
    ensure => file,
    content => "deb http://ubuntu-cloud.archive.canonical.com/ubuntu trusty-updates/kilo main"
  } ->
  exec { 'apt-update':
    command => "/usr/bin/apt-get update",
    timeout => 1800
  } ->
  exec { 'apt-upgrade':
    command => '/usr/bin/apt-get dist-upgrade --yes --force-yes',
    timeout => 1800,
    environment => 'DEBIAN_FRONTEND=noninteractive'
  } ->
  # install curl via apt because fail other dependency if package
  exec { 'installcurl':
    command => '/usr/bin/apt-get install --yes --force-yes curl'
  } ->
  exec { 'touchbaseapt':
    command => 'touch /root/.baseapt'
  }

}

# == Class: pm::base::gitlab
#
# Ensure that we create this custom nginx files before installing gitlab
#
#
# === Authors
#
# Eric Fehr <ricofehr@nextdeploy.io>
#
class pm::base::gitlab {
  Exec {
    path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin", "/opt/bin" ]
  }

  $nextdeployuri = hiera('global::nextdeployuri', 'nextdeploy.local')
  $gitlaburi = hiera('global::gitlaburi', 'gitlab.local')
  $nextdeploysuf = hiera('global::nextdeploysuf', 'os.nextdeploy')

  # Nginx settings
  file { '/etc/os-http.conf':
    ensure =>  file,
    source => ["puppet:///modules/pm/nginx/os-http.conf_${clientcert}",
      'puppet:///modules/pm/nginx/os-http.conf'],
    owner => 'root',
    group => 'root',
    before => Class['::gitlab']
  } ->
  file { '/etc/os-doc.conf':
    ensure =>  file,
    source => ["puppet:///modules/pm/nginx/os-doc.conf_${clientcert}",
      'puppet:///modules/pm/nginx/os-doc.conf'],
    owner => 'root',
    group => 'root',
    before => Class['::gitlab']
  } ->
  file { '/etc/logrotate.d/nginx':
    ensure =>  file,
    source => ["puppet:///modules/pm/nginx/logrotate"],
    owner => 'root',
    group => 'root',
    before => Class['::gitlab']
  } ->
  exec { 'nextdeploysuffix':
    command => "/bin/sed -i 's;%%NEXTDEPLOYSUF%%;${nextdeploysuf};g' /etc/os-http.conf",
    onlyif => 'grep NEXTDEPLOYSUF /etc/os-http.conf',
    user => 'root',
    before => Class['::gitlab']
  } ->
  exec { 'nextdeployuri':
    command => "/bin/sed -i 's;%%NEXTDEPLOYURI%%;${nextdeployuri};g' /etc/os-http.conf",
    onlyif => 'grep NEXTDEPLOYURI /etc/os-http.conf',
    user => 'root',
    before => Class['::gitlab']
  } ->
  exec { 'gitlaburi':
    command => "/bin/sed -i 's;%%GITLABURI%%;${gitlaburi};g' /etc/os-http.conf",
    onlyif => 'grep GITLABURI /etc/os-http.conf',
    user => 'root',
    before => Class['::gitlab']
  } ->
  exec { 'nextdeployuri2':
    command => "/bin/sed -i 's;%%NEXTDEPLOYURI%%;${nextdeployuri};g' /etc/os-doc.conf",
    onlyif => 'grep NEXTDEPLOYURI /etc/os-doc.conf',
    user => 'root',
    before => Class['::gitlab']
  }
}

# == Class: pm::base
#
# Install some common packages and make some standard settings
#
#
# === Authors
#
# Eric Fehr <ricofehr@nextdeploy.io>
#
class pm::base {
  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin", "/opt/bin" ] }

  #list of pkgs
  package { [
        'gpgv',
        'vim',
        'htop',
        'dstat',
        'iotop',
        'strace',
        'rsync',
        'ifstat',
        'links',
        'git-core',
        'ethtool',
        'mailutils'
        ]:
        ensure => installed,
        require => Exec['apt-update']
  }

  #env locals settings
  file { '/etc/environment':
    ensure => file,
    content => "LANGUAGE=en_US.UTF-8
LANG=en_US.UTF-8
LC_ALL=en_US.UTF-8",
  }

  #disable ipv6
  sysctl::value { "net.ipv6.conf.all.disable_ipv6": value => "1"}
  sysctl::value { "net.ipv6.conf.default.disable_ipv6": value => "1"}
  sysctl::value { "net.ipv6.conf.lo.disable_ipv6": value => "1"}

  #avoid swap use
  sysctl::value { "vm.swappiness": value => "0"}
  #tcp tuning
  sysctl::value { "net.ipv4.tcp_max_syn_backlog": value => "8192"}
  sysctl::value { "net.core.somaxconn": value => "2048"}
  sysctl::value { "net.ipv4.tcp_syncookies": value => "1"}
  sysctl::value { "vm.overcommit_memory": value => "1"}

  #ntp class
  include ntp

  exec { 'user-modem':
    command => 'useradd -s /bin/bash -d /home/modem -m modem',
    unless => 'test -d /home/modem'
  } ->
  exec { "rsa-modem":
    command => "ssh-keygen -f /home/modem/.ssh/id_rsa -P ''",
    user => 'modem',
    unless => "test -f /home/modem/.ssh/id_rsa"
  }

  # make bash default shell
  file { '/bin/sh':
    ensure => link,
    target => '/bin/bash'
  }
}
