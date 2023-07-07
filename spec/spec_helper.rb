# frozen_string_literal: true

require 'simplecov'
require 'capybara'
require 'capybara/dsl'
require 'site_prism'

$LOAD_PATH << './lib'
$LOAD_PATH << './features/support'

require_relative 'fixtures/all'
require_relative 'support/all'

Capybara.default_max_wait_time = 0
Capybara.app = SitePrism::Support::App.new

RSpec.configure do |rspec|
  rspec.include SitePrism::Support::HelperMethods
end
