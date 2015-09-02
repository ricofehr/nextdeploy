# == Class: roles::mvmc
#
# Defines the role for manager node installation
#
#
# === Authors
#
# Eric Fehr <eric.fehr@publicis-modem.fr>
#
class roles::mvmc {
  class {'pm::base::apt':} ->
  class {'pm::base':} ->
  class {'pm::hosts':} ->
  class {'pm::gitlab7':} ->
  class {'pm::ror':} ->
  class {'pm::puppet':} ->
  class {'pm::sql':} ->
  class {'pm::phpcli':} ->
  class {'pm::osclient':} ->
  class {'pm::dnsmasq':} ->
  class {'pm::openvpn':} ->
  class {'pm::postinstall::mvmc':} ->
  class {'pm::cron':} ->
  class {'pm::fw':}

  Class['::gitlab'] -> Class['::rvm']
}
