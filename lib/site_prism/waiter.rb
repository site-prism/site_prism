# frozen_string_literal: true

module SitePrism
  # [SitePrism::Waiter]
  class Waiter
    # A looper that will wait until the passed in block evaluates to true
    # Alternatively it will time out once the wait_time is exceeded
    #
    # @return [Boolean]
    def self.wait_until_true(wait_time = Capybara.default_max_wait_time, sleep_duration = 0.05)
      Timer.run(wait_time) do |timer|
        loop do
          return true if yield
          break if timer.done?

          sleep(sleep_duration)
        end
        raise SitePrism::TimeoutError, "Timed out after #{wait_time}s."
      end
    end
  end
end
