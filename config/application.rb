# frozen_string_literal: true

require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_mailbox/engine'
require 'action_text/engine'
require 'action_view/railtie'
require 'action_cable/engine'
# require "sprockets/railtie"
require 'rails/test_unit/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module GrowApi
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0
    config.i18n.default_locale = :ja
    config.time_zone = 'Tokyo'

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.

    # Enable cookies
    config.api_only = false

    # Configure session and cookies middleware
    config.middleware.use ActionDispatch::Cookies
    # config.middleware.use ActionDispatch::Session::CookieStore

    # Cookie settings
    config.middleware.use ActionDispatch::Session::CookieStore, key: '_grow_app_session'
    config.middleware.use ActionDispatch::ContentSecurityPolicy::Middleware
    # config.session_store :cookie_store, key: '_grow_app_session', domain: :all, tld_length: 2

    # Enable csrf_token
    config.action_controller.default_protect_from_forgery = true

    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true
    config.autoload_paths += %W[#{config.root}/lib]

    # stop default generate
    config.generators do |g|
      g.assets false
      g.helper false
      g.test_framework false
    end
  end
end
