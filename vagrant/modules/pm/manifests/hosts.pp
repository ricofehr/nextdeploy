# == Class: pm::hosts
#
# Install a custom hosts file
#
#
# === Authors
#
# Eric Fehr <eric.fehr@publicis-modem.fr>
#
class pm::hosts {
  $pubprefix = hiera('global::pubprefix', '192.168.171')
  $gitlabns = hiera('global::gitlabns', 'gitlab.local')

  file { '/etc/hosts':
    ensure => file,
    source => [
      "puppet:///modules/pm/hosts/hosts"
      ]
  } ->
  exec { 'hostnametolocalhost':
    command => "/bin/sed -i 's;%%GITLABNS%%;${gitlabns};' /etc/hosts"
  } ->
 exec { 'hostnametolocalhost2':
    command => "/bin/sed -i 's;%%HOSTNAME%%;${clientcert};' /etc/hosts"
  } ->
  exec { 'hostnametolocalhost3':
    command => "/bin/sed -i 's;%%PUBPREFIX%%;${pubprefix};g' /etc/hosts"
  }
}
