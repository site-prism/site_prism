# frozen_string_literal: true

require './lib/site_prism/version'

Gem::Specification.new do |s|
  s.name        = 'site_prism'
  s.version     = SitePrism::VERSION
  s.required_ruby_version = '>= 2.3'
  s.platform    = Gem::Platform::RUBY
  s.license     = 'BSD-3-Clause'
  s.authors     = ['Luke Hill', 'Nat Ritmeyer']
  s.email       = %w[lukehill_uk@hotmail.com nat@natontesting.com]
  s.homepage    = 'https://github.com/site-prism/site_prism'
  s.metadata = {
    'bug_tracker_uri' => 'https://github.com/site-prism/site_prism/issues',
    'changelog_uri' => 'https://github.com/site-prism/site_prism/blob/master/CHANGELOG.md',
    'source_code_uri' => 'https://github.com/site-prism/site_prism',
  }
  s.summary     = 'A Page Object Model DSL for Capybara'
  s.description = 'SitePrism gives you a simple,
clean and semantic DSL for describing your site.
SitePrism implements the Page Object Model pattern on top of Capybara.'
  s.files        = Dir.glob('lib/**/*') + %w[LICENSE.md README.md]
  s.require_path = 'lib'
  s.add_dependency 'addressable', ['~> 2.5']
  s.add_dependency 'capybara', ['~> 3.3']
  s.add_dependency 'site_prism-all_there', ['~> 0.3']

  s.add_development_dependency 'cucumber', ['~> 3.1']
  s.add_development_dependency 'rake', ['~> 12.3']
  s.add_development_dependency 'rspec', ['~> 3.8']
  s.add_development_dependency 'rubocop', ['~> 0.73.0']
  s.add_development_dependency 'rubocop-performance', ['~> 1.4.0']
  s.add_development_dependency 'rubocop-rspec', ['~> 1.33.0']
  s.add_development_dependency 'selenium-webdriver', ['~> 3.7']
  s.add_development_dependency 'simplecov', ['~> 0.17']
  s.add_development_dependency 'webdrivers', ['~> 3.9.3']

  s.post_install_message = 'site_prism has now moved to a new organisation to facilitate better
management of the codebase. The new organisation link is available at www.github.com/site-prism
and will house the site_prism gem plus new associated co-dependent gems.'
end
