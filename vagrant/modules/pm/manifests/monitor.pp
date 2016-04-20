# == Class: pm::monitor::services
#
# Install monitor services for store metric datas from remote vms and servers
#
#
# === Authors
#
# Eric Fehr <ricofehr@nextdeploy.io>
#
class pm::monitor::services {
  Exec {
      path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/rvm/bin:/opt/ruby/bin/',
      user => 'root',
  }


  file { '/home/influxdb':
    ensure =>  directory,
    owner => 'root',
    group => 'root',
    mode => '0777'
  } ->
  
  # see parameters from hiera file
  class { 'influxdb::server':
    require => Exec['installcurl']
  }

  file { '/home/grafana':
    ensure =>  directory,
    owner => 'root',
    group => 'root',
    mode => '0777'
  } ->

  class { 'grafana': } ->

  service { 'grafana-server':
    ensure     => running,
    enable     => true
  }

  exec { 'updinflux':
    command => 'apt-get -y update',
    user => 'root'
  }

  # ensure that apt-update is running before install influxdb package
  Apt::Source <| |> ~> Exec['updinflux'] -> Package['influxdb']
}

# == Class: pm::monitor::collect
#
# Collect some sensors from the node
#
#
# === Authors
#
# Eric Fehr <ricofehr@nextdeploy.io>
#
class pm::monitor::collect {
 $influxip = hiera('global::influxip')

 class { 'collectd':
  purge           => true,
  recurse         => true,
  purge_config    => true,
  collectd_hostname => "${clientcert}",
  fqdnlookup => false,
  require => Exec['installcurl'],
 } ->

 collectd::plugin::network::server{"${influxip}":
    port => 2004
 } ->

 class { 'collectd::plugin::conntrack': } ->

 class { 'collectd::plugin::cpu':
  reportbystate => true,
  reportbycpu => true,
  valuespercentage => true,
 } ->

 class { 'collectd::plugin::df':
  mountpoints    => ['/u'],
  fstypes        => ['nfs','tmpfs','autofs','gpfs','proc','devpts'],
  ignoreselected => true,
 } ->

 class { 'collectd::plugin::disk':
  disks          => ['/^dm/'],
  ignoreselected => true,
  udevnameattr   => 'DM_NAME',
 } ->

 class { 'collectd::plugin::interface': } ->

 class { 'collectd::plugin::load': } ->

 class { 'collectd::plugin::processes': } ->

 class { 'collectd::plugin::memory': } ->

 class { 'collectd::plugin::snmp': } ->

 class { 'collectd::plugin::uptime': } ->

 class { 'collectd::plugin::users': } ->

 class { 'collectd::plugin::swap':
    reportbydevice => false,
    reportbytes    => true
  } ->

  class { 'collectd::plugin::syslog':
    log_level => 'warning'
  }
}

# == Class: pm::monitor::collect::varnish
#
# Configure collectd plugin for varnish
#
#
# === Authors
#
# Eric Fehr <ricofehr@nextdeploy.io>
#
class pm::monitor::collect::varnish {
  class { 'collectd::plugin::varnish':
    instances => {
      'instanceName' => {
        'CollectCache' => 'true',
        'CollectBackend' => 'true',
        'CollectConnections' => 'true',
        'CollectSHM' => 'true',
        'CollectESI' => 'false',
        'CollectFetch' => 'true',
        'CollectHCB' => 'false',
        'CollectTotals' => 'true',
        'CollectWorkers' => 'true',
      }
    }
  } ->

  class { 'collectd::plugin::tcpconns':
    localports  => ['80'],
    listening   => true,
  }
}

# == Class: pm::monitor::collect::openvpn
#
# Configure collectd plugin for openvpn
#
#
# === Authors
#
# Eric Fehr <ricofehr@nextdeploy.io>
#
class pm::monitor::collect::openvpn {
  class { 'collectd::plugin::openvpn':
    collectindividualusers => false,
    collectusercount       => true,
  }
}
