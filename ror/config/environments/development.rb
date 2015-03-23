# Global properties for the rails app in developement environment
#
# @author Eric Fehr (eric.fehr@publicis-modem.fr, github: ricofehr)
Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # set logger level
  config.log_level = :warn

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  config.gitlab_endpoint       = 'http://gitlab.local/api/v3' # API endpoint URL, default: ENV['GITLAB_API_ENDPOINT']
  config.gitlab_endpoint0       = 'http://gitlab.local' # API endpoint URL, default: ENV['GITLAB_API_ENDPOINT']
  config.gitlab_prefix       = 'git@mvmc:root/'
  config.mvmcip = '192.168.171.60'

  #config.private_token  = JSON.parse(response.body, symbolize_names: true)[:private_token]
  #config.gitlab_private_token = '1hA4vmgtUezjKSbAcyxF'
  config.gitlab_token = ''
  config.gitlab_rootpath = '/var/opt/gitlab/git-data/repositories/root'
  config.project_initpath = '/home/modem/www'

  config.os_suffix = ".os.mvmc"
  config.os_endpoint = 'http://controller-m:35357'

  config.os_endpoint_neutron = 'http://controller-a:9696'
  config.os_endpoint_nova = 'http://controller-a:8774'
  config.os_endpoint_glance = 'http://glance-a:9292'
  config.os_endpoint_cinder = 'http://controller-a:8776'

  ENV['OS_USERNAME'] ||= 'user'
  ENV['OS_PASSWORD'] ||= 'wordpass'
  ENV['OS_TENANT_NAME'] ||= 'tenant0'
  ENV['OS_AUTH_URL'] ||= 'http://controller-m:35357/v2.0'
end
