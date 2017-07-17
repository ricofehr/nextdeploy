require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module NextDeploy
  # Global properties for the rails app
  #
  # @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
  class Application < Rails::Application
    # Include externals custom apis
    config.autoload_paths += %W(#{config.root}/lib)
    config.autoload_paths += Dir["#{config.root}/lib/**/"]

    # Timezone to paris
    config.time_zone = "Europe/Paris"
    config.active_record.default_timezone = :local

    # AMS adapter
    ActiveModelSerializers.config.adapter = :json

    # disable sql logging
    ActiveRecord::Base.logger = nil
  end
end
