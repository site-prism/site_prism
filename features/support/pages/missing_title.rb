# frozen_string_literal: true

class MissingTitle < SitePrism::Page
  set_url '/missing_title.htm'
  set_url_matcher(/missing_title\.htm$/)

  load_validation { has_message? }

  element :message, 'p'
  elements :missing_messages, 'br'
  sections :missing_sections, 'div' do
    element :not_here, 'div'
  end

  expected_elements :message, :missing_messages
end
