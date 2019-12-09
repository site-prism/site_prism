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

Capybara.register_driver :site_prism do |app|
  browser = ENV.fetch('browser', 'firefox').to_sym
  # Needed whilst we support Webdriver 3.x (Can be removed once we only support 4.x)
  capabilities =
    if browser == :chrome
      { 'chromeOptions' => { 'w3c' => false } }
    else
      {}
    end

  Capybara::Selenium::Driver.new(app, browser: browser, desired_capabilities: capabilities)
end

Capybara.configure do |config|
  config.default_driver = :site_prism
  config.default_max_wait_time = 0.75
  config.app_host = 'file://' + File.dirname(__FILE__) + '/../../test_site'
  config.ignore_hidden_elements = false
end

Webdrivers.cache_time = 86_400
