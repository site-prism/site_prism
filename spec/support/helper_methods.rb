module SitePrism
  module Support
    module HelperMethods
      def capture_stdout
        original_stdout = $stdout
        $stdout = StringIO.new
        yield
        $stdout.string
      ensure
        $stdout = original_stdout
      end

      def lines(string)
        string.split("\n").length
      end
      
      def swallow_missing_element
        yield
      rescue Capybara::ElementNotFound
        :no_op
      end

      def swallow_bad_validation
        yield
      rescue SitePrism::FailedLoadValidationError
        :no_op
      end

      def swallow_timeout
        yield
      rescue SitePrism::TimeoutError
        :no_op
      end

      def wipe_logger!
        return unless SitePrism.instance_variable_get(:@logger)

        SitePrism.remove_instance_variable(:@logger)
      end
    end
  end
end
