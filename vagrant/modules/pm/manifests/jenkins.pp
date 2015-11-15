# == Class: pm::jenkins
#
# Install jenkins
#
#
# === Authors
#
# Eric Fehr <eric.fehr@publicis-modem.fr>
#
class pm::jenkins {

  # jenkins service
  package { 'jenkins':
    ensure => present,
  } ->

  service { 'jenkins':
    ensure => running,
    enable => true,
  }  
}