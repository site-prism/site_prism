# frozen_string_literal: true

require 'simplecov'

require 'automation_helpers/drivers/local'
require 'capybara'
require 'capybara/cucumber'
require 'selenium-webdriver'
require 'webdrivers'

$LOAD_PATH << './lib'

require 'site_prism'

# To prevent natural cucumber load order
require_relative 'js_helper'
require_relative 'time_helper'
require_relative 'sections/all'

SimpleCov.start

browser = ENV.fetch('BROWSER', 'chrome').to_sym
ENV['HEADLESS'] = 'true'
options = AutomationHelpers::Drivers::V4::Options.for(browser)

if browser == :chrome
  options.tap do |opts|
    opts.add_argument('--no-sandbox')
    opts.add_argument('--disable-gpu')
  end
end

AutomationHelpers::Drivers::Local.new(browser, options).register

Capybara.configure do |config|
  config.default_driver = :selenium
  config.default_max_wait_time = 0.75
  config.app_host = "file://#{File.dirname(__FILE__)}/../../test_site"
  config.ignore_hidden_elements = false
end

World(TimeHelper)
