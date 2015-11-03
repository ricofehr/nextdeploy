# == Class: roles::mc2
#
# Defines the role for mc2 node installation
#
#
# === Authors
#
# Eric Fehr <eric.fehr@publicis-modem.fr>
#
class roles::mc2 {
  class {'pm::base::apt':} ->
  class {'pm::base':} ->
  class {'pm::monitor::services':} ->
  class {'pm::monitor::collect':} ->
  class {'pm::hids::server':} ->
  class {'pm::hids::webui':} ->
  class {'pm::varnish':}
}
