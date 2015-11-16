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

  file { '/etc/apt/sources.list.d/jenkins.list':
    ensure => file,
    content => 'deb http://pkg.jenkins-ci.org/debian binary/'
  } ->

  exec { 'aptupdatejenkins':
    command => '/usr/bin/apt-get update',
    timeout => 1800,
    creates => '/usr/share/jenkins/jenkins.war'
  } ->

  # jenkins service
  package { 'jenkins':
    ensure => present,
    install_options => [ '-y', '--force-yes' ]
  } ->

  service { 'jenkins':
    ensure => running,
    enable => true,
  }  
}