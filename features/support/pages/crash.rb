# frozen_string_literal: true

class Crash < SitePrism::Page
  set_url '/slow.htm'
  set_url_matcher(/slow\.htm$/)

  load_validation do
    [
      has_never_here?(wait: 0.05),
      'The Crashed page failed to load correctly'
    ]
  end

  element :never_here, 'strong'
end
