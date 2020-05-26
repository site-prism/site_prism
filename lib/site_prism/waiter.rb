# frozen_string_literal: true

module SitePrism
  class Waiter
    def self.sleep_duration
      0.05
    end

    def self.wait_until_true(wait_time = Capybara.default_max_wait_time)
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
