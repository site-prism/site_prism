# frozen_string_literal: true

class CapybaraOverridingPage < SitePrism::Page
  # Creating some elements that will cause SitePrism to override the default `has_link?` and `has_table?`
  # matchers from Capybara
  element :link, 'a'
  element :table, 'table'
end
