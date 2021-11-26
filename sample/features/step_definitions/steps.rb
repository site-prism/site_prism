require 'capybara/cucumber'
require 'selenium-webdriver'
require 'site_prism'

Capybara.register_driver :site_prism do |app|
  browser = ENV.fetch('browser', 'firefox').to_sym
  Capybara::Selenium::Driver.new(app, browser: browser)
end

# Then tell Capybara to use the Driver you've just defined as its default driver
Capybara.configure do |config|
  config.default_driver = :site_prism
end

# define sections used on multiple pages or multiple times on one page

class Menu < SitePrism::Section
  element :mail, 'a[href*="mail.google.com"]'
  element :news, 'a[href*="news.google.com"]'
  element :calendar, 'a[href*="calendar.google.com"]'
end

class SearchResultsItems < SitePrism::Section
  element :title, 'a', match: :first
  element :blurb, 'div:nth-child(2) > div > span'
end

# define pages

class Home < SitePrism::Page
  set_url 'https://www.google.com/index.html'
  set_url_matcher(/google.com\/?/)

  element :search_field, 'input[name="q"]'
  element :search_button, 'input[name="btnK"]'
  elements :footer_links, '#footer a'
  section :menu, Menu, 'a.gb_C'
end

class SearchResults < SitePrism::Page
  set_url_matcher(/google.com\/search\?.*/)

  section :menu, Menu, 'a.gb_C'
  sections :search_results_items, SearchResultsItems, 'div.g > div > div'

  def search_result_links
    search_results_items.map { |result| result.has_title? ? result.title['href'] : nil }
  end
end

# now for some tests

When(/^I navigate to the google home page$/) do
  @home = Home.new
  @home.load
end

Then(/^the home page should contain the menu and the search form$/) do
  @home.wait_until_menu_visible # menu loads after a second or 2, give it time to arrive
  expect(@home).to have_menu
  expect(@home).to have_search_field
  expect(@home).to have_search_button
end

When(/^I search for Sausages$/) do
  @home.search_field.set 'Sausages'
  @home.search_button.click
end

Then(/^the search results page is displayed$/) do
  @results_page = SearchResults.new
  expect(@results_page).to be_displayed
end

Then(/^the search results page contains 10 individual search results$/) do
  @results_page.wait_until_search_results_items_visible
  expect(@results_page).to have_search_results_items(minimum: 1)
end

Then(/^the search results contain a link to the wikipedia sausages page$/) do
  # english only
  expect(@results_page.search_result_links).to include('wikipedia.org/wiki/Sausage')
end
