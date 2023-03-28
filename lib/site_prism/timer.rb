# frozen_string_literal: true

module SitePrism
  # [SitePrism::Timer]
  #
  # Used to count asynchronously towards an overall desired duration or condition (Block)
  class Timer
    attr_reader :wait_time

    # Count towards a specified time (Supplied)
    #
    # @return [Proc]
    def self.run(wait_time, &block)
      new(wait_time).run(&block)
    end

    def initialize(wait_time)
      @wait_time = wait_time
      @done = false
    end

    # Whether the timer has completed
    #
    # @return [Boolean]
    def done?
      @done == true
    end

    # Start the Timer and re-evaluate the block repeatedly
    #
    # @return [Proc]
    def run
      start
      yield self
    ensure
      stop
    end

    # Start the Timer in a separate process
    #
    # Return [True]
    def start
      stop
      return if wait_time.zero?

      @done = false
      @thread = Thread.start do
        sleep wait_time
        @done = true
      end
    end

    # Forcibly stop the timer, and kill any threads created by it
    #
    # Return [True]
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
