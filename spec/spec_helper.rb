# frozen_string_literal: true

require 'simplecov'

require 'capybara'
require 'capybara/dsl'

$LOAD_PATH << './lib'
$LOAD_PATH << './features/support'

require 'site_prism'
require_relative 'fixtures/all'

Capybara.default_max_wait_time = 0

module SitePrism
  module SpecHelper
    module_function

    def present_on_page
      %i[element_one elements_one section_one sections_one element_three]
    end

    def present_on_section
      %i[inner_element_one inner_element_two iframe]
    end
  end
end

class MyTestApp
  def call(_env)
    [200, { 'Content-Length' => '9' }, ['MyTestApp']]
  end
end

Capybara.app = MyTestApp.new

RSpec.configure do |rspec|
  rspec.include SitePrism::Support::HelperMethods

  [CSSPage, XPathPage].each do |page_klass|
    SitePrism::SpecHelper.present_on_page.each do |method|
      rspec.before do
        @page_instance = page_klass.new
        allow(page_klass).to receive(:new).and_return(@page_instance)

        allow(@page_instance).to receive("has_#{method}?").and_return(true)
        allow(@page_instance).to receive("has_no_#{method}?").and_return(false)
      end
    end
  end

  [CSSSection, XPathSection].each do |section_klass|
    SitePrism::SpecHelper.present_on_section.each do |method|
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
