require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
# require "active_storage/engine"
require 'action_controller/railtie'
require 'action_mailer/railtie'
# require "action_mailbox/engine"
# require "action_text/engine"
require 'action_view/railtie'
# require "action_cable/engine"
require 'rails/test_unit/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TailspendIdam
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    config.assets.paths << Rails.root.join('node_modules/ccs-frontend/dist/ccs/assets')
    config.assets.paths << Rails.root.join('node_modules/govuk-frontend/dist/govuk/assets')

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.before_configuration do
      config.exceptions_app = routes
    end
  end

  def self.google_tag_manager_tracking_id
    @google_tag_manager_tracking_id ||= ENV.fetch('GTM_TRACKING_ID', nil)
  end

  def self.use_gca_branding?
    if ENV['GCA_BRANDING_LIVE_AT']
      Time.zone.now.utc >= Time.zone.parse(ENV['GCA_BRANDING_LIVE_AT']).utc
    else
      false
    end
  end

  def self.cookie_settings_name
    :cookie_preferences_tailspend
  end

  def self.default_cookie_options
    {
      settings_viewed: false,
      usage: false,
      glassbox: false
    }.stringify_keys
  end
end
