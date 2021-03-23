# frozen_string_literal: true

module SitePrism
  # [SitePrism::Deprecator]
  class Deprecator
    class << self
      # @return SitePrism.logger.warn(msg)
      #
      # Tells the user that they are using old functionality, which needs removing in the
      # next major version
      def deprecate(old, new = nil)
        if new
          warn("#{old} is being deprecated and should no longer be used. Use #{new} instead.")
        else
          warn("#{old} is being deprecated and should no longer be used.")
        end

        warn("#{old} will be removed in SitePrism v4. You have been warned!")
      end

      # @return SitePrism.logger.debug(msg)
      #
      # Tells the user that they are using functionality which is non-optimal
      #   The functionality should usually provide a reason for it being poor, as well as an
      #   optional way of upgrading to something different
      #
      # NB: As this is bubbled up at debug level, often users will not see this. So it will
      # never be a candidate for removal directly
      def soft_deprecate(old, reason, new = nil)
        debug("The #{old} method is changing, as is SitePrism, and is now configurable.")
        debug("REASON: #{reason}.")
        debug('Moving forwards into SitePrism v4, the default behaviour will change.')
        debug("We advise you change to using #{new}") if new
      end

      private

      def warn(msg)
        SitePrism.logger.warn(msg)
      end

      def debug(msg)
        SitePrism.logger.debug(msg)
      end
    end
  end
end
