# frozen_string_literal: true

class Dynamic < SitePrism::Page
  set_url '{/letter}.htm'
  set_url_matcher(/\w\.htm$/)

  load_validation do
    has_dummy_section? && has_dummy_element_two?
  end

  section :dummy_section, '.first' do
    element :dummy_element_one, '.second'
  end

  element :dummy_element_two, '.third'
end
