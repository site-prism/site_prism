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

  [CSSPage, XPathPage].each do |page_klass|
    SitePrism::Support::MockedItems.present_on_page.each do |method|
      rspec.before do
        @page_instance = page_klass.new
        allow(page_klass).to receive(:new).and_return(@page_instance)

        allow(@page_instance).to receive("has_#{method}?").and_return(true)
        allow(@page_instance).to receive("has_no_#{method}?").and_return(false)
      end
    end
  end

  [CSSSection, XPathSection].each do |section_klass|
    SitePrism::Support::MockedItems.present_on_section.each do |method|
      rspec.before do
        root_element = instance_double(Capybara::Node::Element)
        section_instance = section_klass.new(
          @page_instance,
          root_element
        )
        allow(section_klass).to receive(:new).and_return(section_instance)

        allow(section_instance).to receive("has_#{method}?").and_return(true)
        allow(section_instance).to receive("has_no_#{method}?").and_return(false)
      end
    end
  end
end
