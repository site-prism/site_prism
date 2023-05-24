# frozen_string_literal: true

class XPathPage < SitePrism::Page
  set_url '/'

  element :element_one, :xpath, '//div[@class="present-wrapper"]//div[@class="valid-one"]'
  element :element_two, :xpath, '//div[@class="present-wrapper"]//div[@class="valid-two"]'
  element :element_three, :xpath, '//span[@class="alert-success"]'

  elements :elements_one, :xpath, '//div[starts-with(@class="valid")]'
  elements :missing_elements_two, :xpath, '//*[@class="many"]'

  element :no_such_element, '//div[@class="present-wrapper"]//div[@class="invalid-one"]'

  section :section_one, XPathSection, :xpath, '//span[@class="locator"]'

  sections :sections_one, Blank, :xpath, '//span[@class="locator"]'

  iframe :iframe, XPathIFrame, :xpath, '//*[@class="iframe"]'

  expected_elements :element_one, :element_two, :element_three, :elements_one, :section_one, :sections_one, :iframe
end
