# frozen_string_literal: true

class CSSPage < SitePrism::Page
  set_url '/'

  element :element_one, 'div.present-wrapper div.valid-one'
  element :element_two, 'div.present-wrapper div.valid-two'
  element :element_three, 'span.alert-success'

  elements :elements_one, 'div[class^=valid]'
  elements :missing_elements_two, '.many'

  element :missing_element, 'div.present-wrapper div.invalid-one'

  section :section_one, CSSSection, 'span.locator'

  sections :sections_one, Blank, 'span.locator'

  iframe :an_iframe, CSSIFrame, '.iframe'

  # missing_element is here to provide negative testing
  expected_elements :element_one, :element_two, :element_three, :elements_one, :section_one, :sections_one, :missing_element, :an_iframe
end
