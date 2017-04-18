# == Class: pm::jenkins
#
# Install jenkins
#
#
# === Authors
#
# Eric Fehr <ricofehr@nextdeploy.io>
#
class pm::jenkins {

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin", "/opt/bin" ] }

  exec { 'jenkinsaptkey':
    command => 'wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -'
  } ->

  file { '/etc/apt/sources.list.d/jenkins.list':
    ensure => file,
    content => 'deb http://pkg.jenkins-ci.org/debian-stable binary/'
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
