# frozen_string_literal: true

module SitePrism
  class Timer
    attr_reader :wait_time

    def self.run(wait_time, &block)
      new(wait_time).run(&block)
    end

    def initialize(wait_time)
      @wait_time = wait_time
      @done = false
    end

    def done?
      @done == true
    end

    def run
      start
      yield self
    ensure
      stop
    end

    def start
      stop
      return if wait_time.zero?

      @done = false
      @thread = Thread.start do
        sleep wait_time
        @done = true
      end
    end

    def stop
      if @thread
        @thread.kill
        @thread.join
        @thread = nil
      end
      @done = true
    end
  end
end
