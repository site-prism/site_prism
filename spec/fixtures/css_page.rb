# frozen_string_literal: true

class CSSPage < SitePrism::Page
  set_url '/'

  element :element_one, 'div.present-wrapper div.valid-one'
  element :element_two, 'div.present-wrapper div.valid-two'
  element :element_three, 'span.alert-success'

  elements :elements_one, 'a.a b.b'
  elements :elements_two, '.many'

  element :no_such_element, 'div.present-wrapper div.invalid-one'

  section :section_one, CSSSection, 'span.locator'

  sections :sections_one, Blank, 'span.locator'

  iframe :iframe, CSSIFrame, '.iframe'

  expected_elements :element_one, :elements_one, :element_three, :section_one, :sections_one, :iframe
end
