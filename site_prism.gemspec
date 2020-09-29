# frozen_string_literal: true

require './lib/site_prism/version'

Gem::Specification.new do |s|
  s.name        = 'site_prism'
  s.version     = SitePrism::VERSION
  s.required_ruby_version = '>= 2.4'
  s.platform    = Gem::Platform::RUBY
  s.license     = 'BSD-3-Clause'
  s.authors     = ['Luke Hill', 'Nat Ritmeyer']
  s.email       = %w[lukehill_uk@hotmail.com nat@natontesting.com]
  s.homepage    = 'https://github.com/site-prism/site_prism'
  s.metadata = {
    'bug_tracker_uri' => 'https://github.com/site-prism/site_prism/issues',
    'changelog_uri' => 'https://github.com/site-prism/site_prism/blob/master/CHANGELOG.md',
    'source_code_uri' => 'https://github.com/site-prism/site_prism'
  }
  s.summary     = 'A Page Object Model DSL for Capybara'
  s.description = 'SitePrism gives you a simple, clean and semantic DSL for describing your site.'\
' SitePrism implements the Page Object Model pattern on top of Capybara.'
  s.files        = Dir.glob('lib/**/*') + %w[LICENSE.md README.md]
  s.require_path = 'lib'
  s.add_dependency 'addressable', ['~> 2.5']
  s.add_dependency 'capybara', ['>= 3.8', '<= 3.33']
  s.add_dependency 'site_prism-all_there', ['>= 0.3.1', '< 1.0']

  s.add_development_dependency 'cucumber', ['~> 3.1']
  s.add_development_dependency 'pry-byebug'
  s.add_development_dependency 'rake', ['>= 12.3']
  s.add_development_dependency 'rspec', ['~> 3.8']
  s.add_development_dependency 'rubocop', ['~> 0.81.0']
  s.add_development_dependency 'rubocop-performance', ['~> 1.5.1']
  s.add_development_dependency 'rubocop-rspec', ['~> 1.33.0']
  s.add_development_dependency 'selenium-webdriver', ['>= 3.9', '< 4.1']
  s.add_development_dependency 'simplecov', ['~> 0.17']
  s.add_development_dependency 'webdrivers', ['~> 4.1']
end
