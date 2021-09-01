# frozen_string_literal: true

module TimeHelper
  def lower_bound_delay
    time_delay / 2
  end

  def upper_bound_delay
    time_delay * 2
  end

  # This is set in the html script `test_site/slow.htm` in the `setTimeout` function
  def time_delay
    0.175
  end
end
