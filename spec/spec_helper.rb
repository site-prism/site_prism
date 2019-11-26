# frozen_string_literal: true

require 'simplecov'

# SimpleCov.start do
#   add_group 'Features', 'features'
#   add_group 'Specs', 'spec'
#   add_group 'Code', 'lib'
# end
#
# SimpleCov.minimum_coverage 99

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

Capybara.app = MyTestApp.new

RSpec.configure do |rspec|
  [CSSPage, XPathPage].each do |page_klass|
    SitePrism::SpecHelper.present_on_page.each do |method|
      rspec.before do
        page_instance = page_klass.new
        allow(page_klass).to receive(:new).and_return(page_instance)

        allow(page_instance).to receive("has_#{method}?").and_return(true)
        allow(page_instance).to receive("has_no_#{method}?").and_return(false)
      end
    end
  end

  [CSSSection, XPathSection].each do |section_klass|
    SitePrism::SpecHelper.present_on_section.each do |method|
      rspec.before do
        allow_any_instance_of(section_klass).to receive("has_#{method}?").and_return(true)
        allow_any_instance_of(section_klass).to receive("has_no_#{method}?").and_return(false)
      end
    end
  end
end
