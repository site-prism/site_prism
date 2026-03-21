# frozen_string_literal: true

class MissingTitle < SitePrism::Page
  set_url '/missing_title.htm'
  set_url_matcher(/missing_title\.htm$/)

  load_validation do
    [
      has_message?,
      'Missing Title page did not load correctly'
    ]
  end

  element :message, 'p'
  elements :missing_messages, 'br'
  sections :missing_sections, 'div' do
    element :not_here, 'div'
  end

  expected_elements :message, :missing_messages
end
