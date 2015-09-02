# == Class: roles::os::uosc
#
# Defines the role for controller node installation
#
#
# === Authors
#
# Eric Fehr <eric.fehr@publicis-modem.fr>
#
class roles::os::uosc {
  class {'pm::base::apt':} ->
  class {'pm::base':} ->
  class {'pm::sql':} ->
  class {'pm::rabbit':} ->
  class {'pm::os::memcached_c':} ->
  class {'pm::hosts':} ->
  class {'pm::osclient':} ->
  class {'pm::os::keystone':} -> 
  class {'pm::os::nv_c':} ->
  class {'pm::os::nt_c':} ->
  class {'pm::os::cder_c':} ->
  class {'pm::os::hz':} ->
  class {'pm::cron':} ->
  class {'pm::fw':}

  Class['pm::base::apt'] -> Class['::rabbitmq']
}


# == Class: roles::os::uosnv
#
# Defines the role for compute node installation
#
#
# === Authors
#
# Eric Fehr <eric.fehr@publicis-modem.fr>
#
class roles::os::uosnv {
  class {'pm::base::apt':} ->
  class {'pm::base':} ->
  class {'pm::hosts':} ->
  class {'pm::osclient':} ->
  class {'pm::os::nv':} ->
  class {'pm::os::nv_postinstall':} ->
  class {'pm::cron':} ->
  class {'pm::fw':}
}


# == Class: roles::os::uosnt
#
# Defines the role for neutron node installation
#
#
# === Authors
#
# Eric Fehr <eric.fehr@publicis-modem.fr>
#
class roles::os::uosnt {
  class {'pm::base::apt':} ->
  class {'pm::base':} ->
  class {'pm::hosts':} ->
  class {'pm::osclient':} ->
  class {'pm::os::nt':} ->
  class {'pm::os::nt_postinstall':} ->
  class {'pm::cron':} ->
  class {'pm::fw':}
}


# == Class: roles::os::uosst
#
# Defines the role for glance node installation
#
#
# === Authors
#
# Eric Fehr <eric.fehr@publicis-modem.fr>
#
class roles::os::uosst {
  class {'pm::base::apt':} ->
  class {'pm::base':} ->
  class {'pm::hosts':} ->
  class {'pm::osclient':} ->
  class {'pm::os::cder':} ->
  class {'pm::os::gl':} ->
  class {'pm::cron':} ->
  class {'pm::fw':}
}
