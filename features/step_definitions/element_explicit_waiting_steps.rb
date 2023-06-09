# frozen_string_literal: true

When('I wait for the element that takes a while to appear') do
  start_time = Time.now
  @test_site.slow.last_link(wait: upper_bound_delay)
  @duration = Time.now - start_time
end

Then('the slow element appears') do
  expect(@test_site.slow).to have_last_link
end

Then("an exception is raised when I wait for an element that won't appear") do
  start_time = Time.now

  expect { @test_site.slow.last_link(wait: lower_bound_delay) }.to raise_error(Capybara::ElementNotFound)

  expect(Time.now - start_time).to be < time_delay
end

Then('I get an error when I wait for an element to vanish within the limit') do
  expect { @test_site.home.wait_until_header_invisible(wait: time_delay) }
    .to raise_error(SitePrism::ElementInvisibilityTimeoutError)
end

Then("an exception is raised when I wait for an element that won't vanish") do
  expect { @test_site.home.wait_until_header_invisible }.to raise_error(SitePrism::ElementInvisibilityTimeoutError)
end

Then('I can wait a variable time for elements to disappear') do
  expect { @test_site.vanishing.removed_elements(wait: upper_bound_delay, count: 0) }.not_to raise_error

  expect(@test_site.vanishing).to have_no_removed_elements
end

Then('I get a timeout error when waiting for an element to become visible within the limit') do
  start_time = Time.now

  expect { @test_site.slow.wait_until_invisible_visible(wait: time_delay) }
    .to raise_error(SitePrism::ElementVisibilityTimeoutError)

  expect(Time.now - start_time).to be_between(time_delay, upper_bound_delay)
end

Then('I get a timeout error when waiting for an element with default limit') do
  expect { @test_site.slow.wait_until_invisible_visible }.to raise_error(SitePrism::ElementVisibilityTimeoutError)
end

When('I wait until a particular element is visible') do
  start_time = Time.now
  @test_site.slow.wait_until_last_link_visible
  @duration = Time.now - start_time
end

Then('the previously invisible element is visible') do
  expect(@test_site.slow.last_link).to be_visible
end

When('I wait for a specific amount of time until an element is visible') do
  start_time = Time.now
  @test_site.slow.wait_until_last_link_visible(wait: upper_bound_delay)
  @duration = Time.now - start_time
end

When('I wait for an element to become invisible') do
  @test_site.vanishing.wait_until_delayed_invisible
end

When('I wait a specific amount of time for a particular element to vanish') do
  @test_site.vanishing.wait_until_delayed_invisible(wait: upper_bound_delay)
end

Then('I am not made to wait for the full default duration') do
  expect(@duration).to be < Capybara.default_max_wait_time
end

Then('I am not made to wait for the full overridden duration') do
  expect(@duration).to be < upper_bound_delay
end

Then('I can override the wait time using a Capybara.using_wait_time block') do
  start_time = Time.now
  Capybara.using_wait_time(lower_bound_delay) do
    expect { @test_site.slow.last_link }.to raise_error(Capybara::ElementNotFound)
  end

  expect(Time.now - start_time).to be_between(lower_bound_delay, upper_bound_delay)
end

Then('I am not made to wait to check a nonexistent element for invisibility') do
  start = Time.new
  @test_site.home.wait_until_nonexistent_element_invisible(wait: lower_bound_delay)

  expect(Time.new - start).to be < upper_bound_delay
end

Then('an error is thrown when waiting for an element in a vanishing section') do
  expect { @test_site.vanishing.container.wait_until_embedded_invisible }.to raise_error(Capybara::ElementNotFound)
end
