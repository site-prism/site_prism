# frozen_string_literal: true

module SitePrism
  module DSL
    # [SitePrism::DSL::Builder]
    #
    # @api private
    #
    # The Building logic - Initially coming from `.build`
    #   This will take a request to build from a DSL invocation such as `element` and generate a series of
    #   helper methods and waiters. It will also generate the correct classes for `SitePrism::Section` objects
    #
    #   Whilst doing all of this, it will also build up a "map" of objects in memory which can be used for
    #   future interrogation. There are 2 ways of this being stored currently (Default as a hash, Legacy as an array)
    #
    module Builder
      # Return a list of all mapped items on a SitePrism class instance (Page or Section)
      # If legacy is set to false (Default) -> @return [Hash]
      # If legacy is set to true (Old behaviour) -> @return [Array]
      def mapped_items(legacy: false)
        return legacy_mapped_items if legacy

        @mapped_items ||= { element: [], elements: [], section: [], sections: [], iframe: [] }
      end

      private

      def build(type, name, *find_args)
        raise InvalidDSLNameError if ENV.fetch('SITEPRISM_DSL_VALIDATION_ENABLED', 'true') == 'true' && invalid?(name)

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
        @legacy_mapped_items ||= begin
          SitePrism::Deprecator.deprecate(
            '.mapped_items structure (internally), on a class',
            'the new .mapped_items structure'
          )
          []
        end
      end

      def map_item(type, name)
        mapped_items(legacy: true) << { type => name }
        mapped_items[type] << name.to_sym
      end

      def extract_section_options(args, &block)
        if args.first.is_a?(Class)
          klass = args.shift
          section_class = klass if klass <= SitePrism::Section
        end

        section_class = deduce_section_class(section_class, &block)
        arguments = deduce_search_arguments(section_class, args)
        [section_class, arguments]
      end

      def deduce_section_class(base_class, &block)
        klass = base_class
        klass = Class.new(klass || SitePrism::Section, &block) if block
        return klass if klass

        raise ArgumentError, 'You should provide descendant of SitePrism::Section class or/and a block as the second argument.'
      end

      def deduce_search_arguments(section_class, args)
        extract_search_arguments(args) ||
          extract_search_arguments(section_class.default_search_arguments) ||
          invalidate_search_arguments!
      end

      def extract_search_arguments(args)
        args if args && !args.empty?
      end

      def invalidate_search_arguments!
        SitePrism.logger.error('Could not deduce search_arguments')
        raise(ArgumentError, 'search arguments are needed in `section` definition or alternatively use `set_default_search_arguments`')
      end
    end
  end
end