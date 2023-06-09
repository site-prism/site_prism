# frozen_string_literal: true

When('I wait an overridden time for the section that takes a while to appear') do
  @test_site.slow.first_section(wait: upper_bound_delay)
end

When('I wait for the section that takes a while to vanish') do
  @test_site.vanishing.wait_until_delayed_section_invisible
end

Then("an exception is raised when I wait for a section that won't appear") do
  expect { @test_site.slow.first_section(wait: lower_bound_delay) }
    .to raise_error(Capybara::ElementNotFound)
end

Then('an error is raised when waiting for the section to vanish') do
  expect { @test_site.vanishing.wait_until_container_invisible }.to raise_error(SitePrism::ElementInvisibilityTimeoutError)
end

Then('the section is no longer visible') do
  expect(@test_site.vanishing.delayed_section).not_to be_visible
end

When('I wait an overridden time for the section to vanish') do
  @test_site.vanishing.wait_until_delayed_section_invisible(wait: upper_bound_delay)
end

Then('the slow section appears') do
  expect(@test_site.slow).to have_first_section
end

Then('an error is raised when waiting an overridden time for the section to vanish') do
  expect { @test_site.vanishing.wait_until_container_invisible(wait: time_delay) }
    .to raise_error(SitePrism::ElementInvisibilityTimeoutError)
end

When('I wait for the collection of sections that takes a while to disappear') do
  @test_site.vanishing.removed_sections(wait: upper_bound_delay, count: 0)
end

Then('the sections are no longer present') do
  expect(@test_site.vanishing).not_to have_removed_sections
end
