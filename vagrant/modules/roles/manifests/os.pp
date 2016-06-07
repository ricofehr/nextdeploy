# == Class: roles::os::uosc
#
# Defines the role for controller node installation
#
#
# === Authors
#
# Eric Fehr <ricofehr@nextdeploy.io>
#
class roles::os::uosc {
  class {'pm::base::apt':} ->
  class {'pm::base':} ->
  class {'pm::sql':} ->
  class {'pm::rabbit':} ->
  class {'pm::os::memcached_c':} ->
  class {'pm::hosts':} ->
  class {'pm::monitor::collect':} ->
  class {'pm::hids::agent':} ->
  class {'pm::osclient':} ->
  class {'pm::os::keystone':} ->
  class {'pm::os::nv_c':} ->
  class {'pm::os::nt_c':} ->
  class {'pm::os::cder_c':} ->
  class {'pm::os::hz':} ->
  class {'pm::os::backup_c':} ->
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
# Eric Fehr <ricofehr@nextdeploy.io>
#
class roles::os::uosnv {
  # get variable who say if this nova is the first and main compute node
  $is_nv0 = hiera("is_nv0", "no")

  class {'pm::base::apt':} ->
  class {'pm::base':} ->
  class {'pm::hosts':} ->
  class {'pm::monitor::collect':} ->
  class {'pm::hids::agent':} ->
  class {'pm::osclient':} ->
  class {'pm::os::nv':} ->
  class {'pm::os::nv_postinstall':} ->
  class {'pm::cron':} ->
  class {'pm::fw':}

  if $is_nv0 == "yes" {
    class {'pm::os::nv0_postinstall':
      require => Class['pm::os::nv_postinstall']
    }
  }
}


# == Class: roles::os::uosnt
#
# Defines the role for neutron node installation
#
#
# === Authors
#
# Eric Fehr <ricofehr@nextdeploy.io>
#
class roles::os::uosnt {
  class {'pm::base::apt':} ->
  class {'pm::base':} ->
  class {'pm::hosts':} ->
  class {'pm::monitor::collect':} ->
  class {'pm::hids::agent':} ->
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
# Eric Fehr <ricofehr@nextdeploy.io>
#
class roles::os::uosst {
  class {'pm::base::apt':} ->
  class {'pm::base':} ->
  class {'pm::hosts':} ->
  class {'pm::monitor::collect':} ->
  class {'pm::hids::agent':} ->
  class {'pm::osclient':} ->
  class {'pm::os::cder':} ->
  class {'pm::os::gl':} ->
  class {'pm::cron':} ->
  class {'pm::fw':}
}
