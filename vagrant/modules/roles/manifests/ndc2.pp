# == Class: roles::ndc2
#
# Defines the role for ndc2 (NextDeploy Control Center) node installation
#
#
# === Authors
#
# Eric Fehr <eric.fehr@publicis-modem.fr>
#
class roles::ndc2 {
  class {'pm::base::apt':} ->
  class {'pm::base':} ->
  class {'pm::pound':} ->
  class {'pm::jenkins':} ->
  class {'pm::w3af':} ->
  class {'pm::monitor::services':} ->
  class {'pm::monitor::collect':} ->
  class {'pm::hids::server':} ->
  class {'pm::hids::webui':} ->
  class {'pm::varnish':}
}
