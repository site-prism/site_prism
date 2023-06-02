# frozen_string_literal: true

module SitePrism
  module DSL
    #
    # @api private
    #
    # ~~~~~~~~~~~~~ TEMP DOCUMENTATION ~~~~~~~~~~~~~
    #
    # This is a newly migrated experimental way of partitioning the SitePrism internal DSL
    #
    # It is currently completely switched off and disabled / untested, and will remain this way for all of v4
    #
    # ~~~~~~~~~~~~~~~
    #
    # [SitePrism::DSL::Locators]
    #
    # The locator logic for scoping and accessing all items, boolean tests and waiters
    #
    module Locators
      def self.included
        SitePrism.logger.error('The new experimental DSL partitioning has been required. Code will now crash!')
        raise SitePrismError
      end

      private

      def _find(*find_args)
        kwargs = find_args.pop
        to_capybara_node.find(*find_args, **kwargs)
      end

      def _all(*find_args)
        kwargs = find_args.pop
        to_capybara_node.all(*find_args, **kwargs)
      end

      def element_exists?(*find_args)
        kwargs = find_args.pop
        to_capybara_node.has_selector?(*find_args, **kwargs)
      end

      def element_does_not_exist?(*find_args)
        kwargs = find_args.pop
        to_capybara_node.has_no_selector?(*find_args, **kwargs)
      end

      # Sanitize method called before calling any SitePrism DSL method or
      # meta-programmed method. This ensures that the Capybara query is correct.
      #
      # Accepts any combination of arguments sent at DSL definition or runtime
      # and combines them in such a way that Capybara can operate with them.
      def merge_args(find_args, runtime_args, visibility_args = {})
        find_args = find_args.dup
        runtime_args = runtime_args.dup
        options = visibility_args.dup
        SitePrism.logger.debug("Initial args: #{find_args}, #{runtime_args}.")

        recombine_args(find_args, runtime_args, options)

        return [*find_args, *runtime_args, {}] if options.empty?

        [*find_args, *runtime_args, options]
      end

      # Options re-combiner. This takes the original inputs and combines
      # them such that there is only one hash passed as a final argument
      # to Capybara.
      #
      # If the hash is empty, then the hash is omitted from the payload sent
      # to Capybara, and the find / runtime arguments are sent alone.
      #
      # NB: If the +wait+ key is present in the options hash, even as false or 0, It will
      # be set as the user-supplied value (So user error can be the cause for issues).
      def recombine_args(find_args, runtime_args, options)
        options.merge!(find_args.pop) if find_args.last.is_a? Hash
        options.merge!(runtime_args.pop) if runtime_args.last.is_a? Hash
        options[:wait] = Capybara.default_max_wait_time unless options.key?(:wait)
      end
    end
  end
end
