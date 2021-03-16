# frozen_string_literal: true

module SitePrism
  # [SitePrism::Timer]
  #
  # Used to count asynchronously towards an overall desired duration or condition (Block)
  class Timer
    attr_reader :wait_time

    # Return &block
    #
    # Count towards a specified time (Supplied)
    def self.run(wait_time, &block)
      new(wait_time).run(&block)
    end

    def initialize(wait_time)
      @wait_time = wait_time
      @done = false
    end

    # Return Boolean
    #
    # Whether the timer has completed
    def done?
      @done == true
    end

    # Return &block
    #
    # Start the Timer and re-evaluate the block repeatedly
    def run
      start
      yield self
    ensure
      stop
    end

    # Return [Boolean, Nil]
    #
    # Start the Timer in a separate process
    def start
      stop
      return if wait_time.zero?

      @done = false
      @thread = Thread.start do
        sleep wait_time
        @done = true
      end
    end

    # Return True
    #
    # Forcibly stop the timer, and kill any threads created by it
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
