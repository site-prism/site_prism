# frozen_string_literal: true

class CSSSection < SitePrism::Section
  element :inner_element_one, '.one'
  element :inner_element_two, '.two'
  iframe :an_iframe, CSSIFrame, '.iframe'
end
