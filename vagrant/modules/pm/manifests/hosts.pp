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
  $apiprefix = hiera('global::apiprefix', '192.168.170')
  $managementprefix = hiera('global::managementprefix', '172.16.170')
  $dataprefix = hiera('global::dataprefix', '172.16.171')
  $gitlabns = hiera('global::gitlabns', 'gitlab.local')

  file { '/etc/hosts':
    ensure => file,
    source => [
      "puppet:///modules/pm/hosts/hosts_${clientcert}",
      "puppet:///modules/pm/hosts/hosts"
      ],
    owner => 'root',
    group => 'root'
  } ->
  exec { 'hostnametolocalhost':
    command => "/bin/sed -i 's;%%GITLABNS%%;${gitlabns};' /etc/hosts",
    onlyif => '/bin/grep GITLABNS /etc/hosts'
  } ->
  exec { 'hostnametolocalhost2':
    command => "/bin/sed -i 's;%%HOSTNAME%%;${clientcert};' /etc/hosts",
    onlyif => '/bin/grep HOSTNAME /etc/hosts'
  } ->
  exec { 'hostnametolocalhost3':
    command => "/bin/sed -i 's/%%PUBPREFIX%%/${pubprefix}/g;s/%%APIPREFIX%%/${apiprefix}/g;' /etc/hosts",
    onlyif => '/bin/grep PUBPREFIX /etc/hosts'
  } ->
  exec { 'hostnametolocalhost4':
    command => "/bin/sed -i 's/%%MANAGEMENTPREFIX%%/${managementprefix}/g;s/%%DATAPREFIX%%/${dataprefix}/g;' /etc/hosts",
    onlyif => '/bin/grep MANAGEMENTPREFIX /etc/hosts'
  }
}
