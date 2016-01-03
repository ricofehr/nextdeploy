# == Class: pm::rabbit
#
# Install rabbitmq with help of official module
#
#
# === Authors
#
# Eric Fehr <ricofehr@nextdeploy.io>
#
class pm::rabbit {
  class { 'rabbitmq': }

  create_resources ('rabbitmq_user', hiera('rabbitmq_user', []))
  create_resources ('rabbitmq_user_permissions', hiera('rabbitmq_user_permissions', []))
}
