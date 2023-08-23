# frozen_string_literal: true

require 'simplecov'

require 'capybara'
require 'capybara/cucumber'
require 'selenium-webdriver'

$LOAD_PATH << './lib'

require 'site_prism'

# To prevent natural cucumber load order
require_relative 'js_helper'
require_relative 'time_helper'
require_relative 'sections/all'

SimpleCov.start if defined?(SimpleCov) && RUBY_VERSION < '3.1'

browser = ENV.fetch('BROWSER', 'chrome').to_sym
AutomationHelpers::Drivers::Local.new(browser).register

Capybara.configure do |config|
  config.default_driver = :selenium
  config.default_max_wait_time = 0.75
  config.app_host = "file://#{File.dirname(__FILE__)}/../../test_site"
  config.ignore_hidden_elements = false
end

World(TimeHelper)
