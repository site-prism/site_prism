# frozen_string_literal: true

module SitePrism
  module DSL
    # [SitePrism::DSL::Builder]
    #
    # This is a newly migrated experimental way of partitioning the SitePrism internal DSL
    #
    # It is currently completely switched off and disabled / untested, and will remain this way for all of v4
    #
    # ~~~~~~~~~~~~~ PREVIOUS DOCUMENTATION ~~~~~~~~~~~~~
    #
    # [SitePrism::DSL::ClassMethods]
    #
    # No docs present - all private
    module Builder
      private

      def raise_if_runtime_block_supplied(object, name, has_block, type)
        return unless has_block

        SitePrism.logger.debug("Type passed in: #{type}")
        SitePrism.logger.error("#{object.class}##{name} cannot accept runtime blocks")
        raise SitePrism::UnsupportedBlockError
      end

      def build(type, name, *find_args)
        raise InvalidDSLNameError if ENV.fetch('SITEPRISM_DSL_VALIDATION_ENABLED', nil) && invalid?(name)

        if find_args.empty?
          create_error_method(name)
        else
          map_item(type, name)
          yield
        end
        add_helper_methods(name, type, *find_args)
      end

      def create_error_method(name)
        SitePrism::Deprecator.deprecate(
          'DSL definition with no find_args',
          'DSL definition with at least 1 find_arg'
        )
        SitePrism.logger.error("#{name} has come from an item with no locators.")
        define_method(name) { raise SitePrism::InvalidElementError }
      end
    end
  end
end
