# frozen_string_literal: true

require 'simplecov'

require 'capybara'
require 'capybara/cucumber'
require 'selenium-webdriver'
require 'webdrivers'

$LOAD_PATH << './lib'

require 'site_prism'

# To prevent natural cucumber load order
require_relative 'js_helper'
require_relative 'sections/all'

SimpleCov.start if defined? SimpleCov

Capybara.register_driver :site_prism do |app|
  browser = ENV.fetch('browser', 'chrome').to_sym
  Capybara::Selenium::Driver.new(app, browser: browser)
end

Capybara.configure do |config|
  config.default_driver = :site_prism
  config.default_max_wait_time = 0.75
  config.app_host = "file://#{File.dirname(__FILE__)}/../../test_site"
  config.ignore_hidden_elements = false
end

Webdrivers.cache_time = 86_400

# This will be required until v4 of SitePrism is released
require 'site_prism/all_there'
SitePrism.use_all_there_gem = true
