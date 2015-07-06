# == Class: pm::base::apt
#
# Ensure that we make apt-update before installing packages
#
#
# === Authors
#
# Eric Fehr <eric.fehr@publicis-modem.fr>
#
class pm::base::apt {
    include apt

  exec { "apt-update":
    command => "/usr/bin/apt-get update",
    timeout => 1800
  }

  Class['pm::base::apt'] -> Package<| |>
}

# == Class: pm::base
#
# Install some common packages and make some standard settings
#
#
# === Authors
#
# Eric Fehr <eric.fehr@publicis-modem.fr>
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
        'ethtool'
        ]:
        ensure => installed,
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
  #sysctl::value { "net.nf_conntrack_max": value => "262144"}

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
  exec { 'bashdefaultshell':
    command => 'ln -sf /bin/bash /bin/sh'
  }
}
