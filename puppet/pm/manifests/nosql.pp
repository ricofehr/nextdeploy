# == Class: pm::nosql::mongo
#
# Install mongodb with help of official module
#
#
# === Authors
#
# Eric Fehr <eric.fehr@publicis-modem.fr>
#
class pm::nosql::mongo {
  #mongo setting
  class {'::mongodb::globals':
  manage_package_repo => true,
  }
  ->
  class {'::mongodb::server': }
}


# == Class: pm::nosql::memcache
#
# Install mongodb with help of official module
#
#
# === Authors
#
# Eric Fehr <eric.fehr@publicis-modem.fr>
#
class pm::nosql::memcache {
  #memcached setting
  class { 'memcached':
    max_memory => 2048,
    tcp_port => '11211',
    udp_port => '11211',
    listen_ip => '127.0.0.1'
  }
}


# == Class: pm::nosql::redis
#
# Install redis with help of official module
#
#
# === Authors
#
# Eric Fehr <eric.fehr@publicis-modem.fr>
#
class pm::nosql::redis {
  #redis setting
  class { '::redis': }
}