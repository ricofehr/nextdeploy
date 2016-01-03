# == Class: roles::nextdeploy
#
# Defines the role for manager node installation
#
#
# === Authors
#
# Eric Fehr <ricofehr@nextdeploy.io>
#
class roles::nextdeploy {
  # for avoid aptupdate dependency issue,
  # start with gitlab
  class {'pm::base::gitlab':} ->
  class {'pm::gitlab7':} ->
  class {'pm::base::apt':} ->
  class {'pm::base':} ->
  class {'pm::hosts':} ->
  class {'pm::monitor::collect':} ->
  class {'pm::hids::agent':} ->
  class {'pm::pound':} ->
  class {'pm::ror':} ->
  class {'pm::puppet':} ->
  class {'pm::sql':} ->
  class {'pm::phpcli':} ->
  class {'pm::osclient':} ->
  class {'pm::dnsmasq':} ->
  class {'pm::openvpn':} ->
  class {'pm::ftp':} ->
  class {'pm::postinstall::exploitation':} ->
  class {'pm::postinstall::nextdeploy':} ->
  class {'pm::cron':} ->
  class {'pm::fw':}
}
