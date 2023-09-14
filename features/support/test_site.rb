# frozen_string_literal: true

class TestSite
  def crash
    @crash ||= Crash.new
  end

  def delayed
    @delayed ||= Delayed.new
  end

  def dynamic
    @dynamic ||= Dynamic.new
  end

  def home
    @home ||= Home.new
  end

  def missing_title
    @missing_title ||= MissingTitle.new
  end

  def nested_sections
    @nested_sections ||= NestedSections.new
  end

  def redirect
    @redirect ||= Redirect.new
  end

  def shadow_root
    @shadow_root ||= ShadowRoot.new
  end

  def slow
    @slow ||= Slow.new
  end

  def vanishing
    @vanishing ||= Vanishing.new
  end
end
