# == Class: pm::cron
#
# Install crontab from lines defined into hiera file
#
#
# === Authors
#
# Eric Fehr <ricofehr@nextdeploy.io>
#
class pm::cron {
  $is_cron = hiera("is_cron", "no")
  if $is_cron == "yes" {
    $cron_params = hiera("cron_cmd", [])
    create_resources("cron", $cron_params)
  }
}
