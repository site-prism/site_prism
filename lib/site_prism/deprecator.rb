# frozen_string_literal: true

module SitePrism
  # [SitePrism::Deprecator]
  class Deprecator
    class << self
      # @return [SitePrism.logger.warn(msg)]
      #
      # Tells the user that they are using old functionality, which needs removing in the
      # next major version
      def deprecate(old, new = nil)
        if new
          warn("#{old} is being deprecated and should no longer be used. Use #{new} instead.")
        else
          warn("#{old} is being deprecated and should no longer be used.")
        end

        warn("#{old} will be removed in SitePrism v6. You have been warned!")
      end

      private

      def warn(msg)
        SitePrism.logger.warn(msg)
      end
    end
  end
end
