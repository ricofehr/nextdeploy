# == Class: pm::openvpn
#
# Install an openvpn server with help of luxflux module
#
#
# === Authors
#
# Eric Fehr <ricofehr@nextdeploy.io>
#
class pm::openvpn {
  $server = hiera('vpnserver', [])
  create_resources('::openvpn::server', $server)

  class { 'pm::monitor::collect::openvpn': }
}
