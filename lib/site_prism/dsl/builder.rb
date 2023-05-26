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

      class << self
        # Return a list of all mapped items on a SitePrism class instance (Page or Section)
        # If legacy is set to true (Default) -> @return [Array]
        # If legacy is set to false (New behaviour) -> @return [Hash]
        def mapped_items(legacy: false)
          return legacy_mapped_items if legacy

          @mapped_items ||= { element: [], elements: [], section: [], sections: [], iframe: [] }
        end

        private

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

        def add_helper_methods(name, _type, *find_args)
          create_existence_checker(name, *find_args)
          create_nonexistence_checker(name, *find_args)
          SitePrism::RSpecMatchers.new(name)._create_rspec_existence_matchers if defined?(RSpec)
          create_visibility_waiter(name, *find_args)
          create_invisibility_waiter(name, *find_args)
        end

        def create_existence_checker(element_name, *find_args)
          method_name = "has_#{element_name}?"
          create_helper_method(method_name, *find_args) do
            define_method(method_name) do |*runtime_args|
              args = merge_args(find_args, runtime_args)
              element_exists?(*args)
            end
          end
        end

        def create_nonexistence_checker(element_name, *find_args)
          method_name = "has_no_#{element_name}?"
          create_helper_method(method_name, *find_args) do
            define_method(method_name) do |*runtime_args|
              args = merge_args(find_args, runtime_args)
              element_does_not_exist?(*args)
            end
          end
        end

        def create_visibility_waiter(element_name, *find_args)
          method_name = "wait_until_#{element_name}_visible"
          create_helper_method(method_name, *find_args) do
            define_method(method_name) do |*runtime_args|
              args = merge_args(find_args, runtime_args, visible: true)
              return true if element_exists?(*args)

              raise SitePrism::ElementVisibilityTimeoutError
            end
          end
        end

        def create_invisibility_waiter(element_name, *find_args)
          method_name = "wait_until_#{element_name}_invisible"
          create_helper_method(method_name, *find_args) do
            define_method(method_name) do |*runtime_args|
              args = merge_args(find_args, runtime_args, visible: true)
              return true if element_does_not_exist?(*args)

              raise SitePrism::ElementInvisibilityTimeoutError
            end
          end
        end

        def create_helper_method(proposed_method_name, *find_args)
          return create_error_method(proposed_method_name) if find_args.empty?

          yield
        end

        def legacy_mapped_items
          SitePrism::Deprecator.deprecate(
            '.mapped_items structure (internally), on a class',
            'Thew new .mapped_items structure'
          )
          @legacy_mapped_items ||= []
        end

        def map_item(type, name)
          mapped_items(legacy: true) << { type => name }
          mapped_items[type] << name.to_sym
        end
      end
    end
  end
end
