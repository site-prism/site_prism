# frozen_string_literal: true

class ShadowRoot < SitePrism::Page
  set_url '/shadow_root.htm'
  set_url_matcher(/shadow_root\.htm$/)

  # shadow-root
  section :shadow_root_section, '#shadow-root', :shadow_root do
    element :some_text, 'p'
  end
end
