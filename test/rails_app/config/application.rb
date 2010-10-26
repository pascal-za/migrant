require File.expand_path('../boot', __FILE__)

require "action_controller/railtie"
require "action_mailer/railtie"
require "active_record/railtie"
require 'railtie'

module RailsApp
  class Application < Rails::Application
    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"
  end
end

require 'rake'
RailsApp::Application.load_tasks
