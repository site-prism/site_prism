# frozen_string_literal: true

module TimeHelper
  def lower_bound_delay
    time_delay / 3
  end

  # We need to allow some leeway with our tests taking longer than expected due to infrastructure issues
  def upper_bound_delay
    time_delay * 3
  end

  # This is set in the html script `test_site/slow.htm` in the `setTimeout` function
  def time_delay
    0.175
  end
end
