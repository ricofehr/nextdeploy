# == Class: pm::rabbit
#
# Install rabbitmq with help of official module
#
#
# === Authors
#
# Eric Fehr <eric.fehr@publicis-modem.fr>
#
class pm::rabbit {
  #rabbit setting
  class { 'rabbitmq': }

  #create_resources ('rabbitmq_user', hiera('rabbitmq_user', []))
  #create_resources ('rabbitmq_user_permissions', hiera('rabbitmq_user_permissions', []))
}
