# Setup for ossec client
class ossec::client(
  $ossec_active_response   = true,
  $ossec_server_ip,
  $ossec_emailnotification = 'yes',
  $selinux = false,
) {
  include ossec::common

  case $::osfamily {
    'Debian' : {
      package { $ossec::common::hidsagentpackage:
        ensure  => installed,
        require => Apt::Source['alienvault-ossec'],
      }
    }
    'RedHat' : {
      package { 'ossec-hids':
        ensure  => installed,
        require => Yumrepo['ossec'],
      }
      package { $ossec::common::hidsagentpackage:
        ensure  => installed,
        require => Package['ossec-hids'],
      }
    }
    default: { fail('OS family not supported') }
  }

  service { $ossec::common::hidsagentservice:
    ensure    => running,
    enable    => true,
    hasstatus => $ossec::common::servicehasstatus,
    pattern   => $ossec::common::hidsagentservice,
    require   => Package[$ossec::common::hidsagentpackage],
  }

  concat { '/var/ossec/etc/ossec.conf':
    owner   => 'root',
    group   => 'ossec',
    mode    => '0440',
    require => Package[$ossec::common::hidsagentpackage],
    notify  => Service[$ossec::common::hidsagentservice]
  }
  concat::fragment { 'ossec.conf_10' :
    target  => '/var/ossec/etc/ossec.conf',
    content => template('ossec/10_ossec_agent.conf.erb'),
    order   => 10,
    notify  => Service[$ossec::common::hidsagentservice]
  }
  concat::fragment { 'ossec.conf_99' :
    target  => '/var/ossec/etc/ossec.conf',
    content => template('ossec/99_ossec_agent.conf.erb'),
    order   => 99,
    notify  => Service[$ossec::common::hidsagentservice]
  }

    exec { 'agent-auth':
      command => "/var/ossec/bin/agent-auth -m ${ossec_server_ip} -A ${::fqdn} -D /var/ossec/",
      creates => '/var/ossec/etc/client.keys',
      require => Package[$ossec::common::hidsagentpackage]
    }

  # Set log permissions properly to fix
  # https://github.com/djjudas21/puppet-ossec/issues/20
  file { '/var/ossec/logs':
    ensure  => directory,
    require => Package[$ossec::common::hidsagentpackage],
    owner   => 'ossec',
    group   => 'ossec',
    mode    => '0755',
    seltype => 'var_log_t',
  }

  # SELinux policy isn't needed any more
  if ($::osfamily == 'RedHat' and $selinux == true) {
    selinux::module { 'ossec-logrotate':
      ensure => 'absent',
      source => 'puppet:///modules/ossec/ossec-logrotate.te',
    }
  }

  # Fix up the logrotate file with sensible defaults
    file { '/etc/logrotate.d/ossec-hids':
    ensure  => file,
    source => 'puppet:///modules/ossec/ossec-hids',
    require => Package[$ossec::common::hidsagentpackage],
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }
}

