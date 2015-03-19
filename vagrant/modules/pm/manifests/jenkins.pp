# == Class: pm::jenkins
#
# Install jenkins for current node (properties from hiera file)
#
#
# === Authors
#
# Eric Fehr <eric.fehr@publicis-modem.fr>
#
class pm::jenkins {
  class { '::jenkins': }
}