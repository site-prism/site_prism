# frozen_string_literal: true

Then('an exception is raised when I deal with an element with no selector') do
  expect { @test_site.missing_title.has_element_without_selector? }.to raise_error(SitePrism::InvalidElementError)
  expect { @test_site.missing_title.element_without_selector }.to raise_error(SitePrism::InvalidElementError)
  expect { @test_site.missing_title.wait_until_element_without_selector_visible }.to raise_error(SitePrism::InvalidElementError)
end

Then('an exception is raised when I deal with elements with no selector') do
  expect { @test_site.missing_title.has_elements_without_selector? }.to raise_error(SitePrism::InvalidElementError)
  expect { @test_site.missing_title.elements_without_selector }.to raise_error(SitePrism::InvalidElementError)
  expect { @test_site.missing_title.wait_until_elements_without_selector_visible }.to raise_error(SitePrism::InvalidElementError)
end
