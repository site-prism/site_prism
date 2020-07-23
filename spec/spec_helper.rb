# frozen_string_literal: true

require 'simplecov'

require 'capybara'
require 'capybara/dsl'

$LOAD_PATH << './lib'
$LOAD_PATH << './features/support'

require 'site_prism'
require_relative 'fixtures/all'

Capybara.default_max_wait_time = 0

# This will be required until v4 of SitePrism is released
require 'site_prism/all_there'
SitePrism.use_all_there_gem = true

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

def capture_stdout
  original_stdout = $stdout
  $stdout = StringIO.new
  yield
  $stdout.string
ensure
  $stdout = original_stdout
end

def wipe_logger!
  return unless SitePrism.instance_variable_get(:@logger)

  SitePrism.remove_instance_variable(:@logger)
end

def lines(string)
  string.split("\n").length
end

def swallow_missing_element
  yield
rescue Capybara::ElementNotFound
  :no_op
end

def swallow_bad_validation
  yield
rescue SitePrism::FailedLoadValidationError
  :no_op
end

Capybara.app = MyTestApp.new

RSpec.configure do |rspec|
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
