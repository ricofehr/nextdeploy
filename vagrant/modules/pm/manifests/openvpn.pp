# == Class: pm::openvpn
#
# Install an openvpn server with help of luxflux module
#
#
# === Authors
#
# Eric Fehr <eric.fehr@publicis-modem.fr>
#
class pm::openvpn {
  $server = hiera('vpnserver', [])
  create_resources('::openvpn::server', $server)
}
