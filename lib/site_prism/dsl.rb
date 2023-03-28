# frozen_string_literal: true

module SitePrism
  # [SitePrism::DSL]
  #
  # This is the core Module Namespace for all of the public-facing DSL methods
  #   such as `element`. The code here is designed to be used through the defining
  #   of said items, and not to be instantiated directly.
  #
  # The whole package here can be thought of as [@api private]
  module DSL
    def self.included(klass)
      klass.extend ClassMethods
      klass.extend DSLValidator
    end

    private

    def raise_if_runtime_block_supplied(object, name, has_block, type)
      return unless has_block

      SitePrism.logger.debug("Type passed in: #{type}")
      SitePrism.logger.error("#{object.class}##{name} cannot accept runtime blocks")
      raise SitePrism::UnsupportedBlockError
    end

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

    # [SitePrism::DSL::ClassMethods]
    # This exposes all of the DSL definitions users will use when generating
    # their POM classes.
    #
    # Many of these methods will be used in-line to allow users to generate a multitude of
    # methods and locators for finding elements / sections on a page or section of a page
    module ClassMethods
      attr_reader :expected_items

      # Sets the `expected_items` iVar on a class. This property is used in conjunction with
      # `all_there?` to provide a way of granularising the check made to only interrogate a sub-set
      # of DSL defined items
      def expected_elements(*elements)
        @expected_items = elements
      end

      # Creates an instance of a SitePrism Element - This will create several methods designed to
      # Locate the element -> @return [Capybara::Node::Element]
      # Check the elements presence or non-presence -> @return [Boolean]
      # Wait for the elements to be present or not -> @return [TrueClass, SitePrism::Error]
      # Validate certain properties about the element
      def element(name, *find_args)
        raise_if_build_time_block_supplied(self, name, block_given?, :element)
        build(:element, name, *find_args) do
          define_method(name) do |*runtime_args, &runtime_block|
            raise_if_runtime_block_supplied(self, name, runtime_block, :element)
            _find(*merge_args(find_args, runtime_args))
          end
        end
      end

      # Creates a enumerable instance of a SitePrism Element - This will create several methods designed to
      # Locate the enumerable element -> @return [Capybara::Result]
      # Check the elements presence or non-presence -> @return [Boolean]
      # Wait for the elements to be present or not -> @return [TrueClass, SitePrism::Error]
      # Validate certain properties about the elements
      def elements(name, *find_args)
        raise_if_build_time_block_supplied(self, name, block_given?, :elements)
        build(:elements, name, *find_args) do
          define_method(name) do |*runtime_args, &runtime_block|
            raise_if_runtime_block_supplied(self, name, runtime_block, :elements)
            _all(*merge_args(find_args, runtime_args))
          end
        end
      end

      # Creates an instance of a SitePrism Section - This will create several methods designed to
      # Locate the section -> @return [SitePrism::Section]
      # Check the section presence or non-presence -> @return [Boolean]
      # Wait for the section to be present or not -> @return [TrueClass, SitePrism::Error]
      # Validate certain properties about the section
      def section(name, *args, &block)
        section_class, find_args = extract_section_options(args, &block)
        build(:section, name, *find_args) do
          define_method(name) do |*runtime_args, &runtime_block|
            section_element = _find(*merge_args(find_args, runtime_args))
            section_class.new(self, section_element, &runtime_block)
          end
        end
      end

      # Creates an enumerable instance of a SitePrism Section - This will create several methods designed to
      # Locate the sections -> @return [Array]
      # Check the sections presence or non-presence -> @return [Boolean]
      # Wait for the sections to be present or not -> @return [TrueClass, SitePrism::Error]
      # Validate certain properties about the section
      def sections(name, *args, &block)
        section_class, find_args = extract_section_options(args, &block)
        build(:sections, name, *find_args) do
          define_method(name) do |*runtime_args, &runtime_block|
            raise_if_runtime_block_supplied(self, name, runtime_block, :sections)
            _all(*merge_args(find_args, runtime_args)).map do |element|
              section_class.new(self, element)
            end
          end
        end
      end

      def iframe(name, klass, *args)
        raise_if_build_time_block_supplied(self, name, block_given?, :elements)
        element_find_args = deduce_iframe_element_find_args(args)
        scope_find_args = deduce_iframe_scope_find_args(args)
        build(:iframe, name, *element_find_args) do
          define_method(name) do |&block|
            raise MissingBlockError unless block

            within_frame(*scope_find_args) { block.call(klass.new) }
          end
        end
      end

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

      def add_helper_methods(name, _type, *find_args)
        create_existence_checker(name, *find_args)
        create_nonexistence_checker(name, *find_args)
        SitePrism::RspecMatchers.new(name)._create_rspec_existence_matchers if defined?(RSpec)
        create_visibility_waiter(name, *find_args)
        create_invisibility_waiter(name, *find_args)
      end

      def create_helper_method(proposed_method_name, *find_args)
        return create_error_method(proposed_method_name) if find_args.empty?

        yield
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

      def create_error_method(name)
        SitePrism::Deprecator.deprecate(
          'DSL definition with no find_args',
          'DSL definition with at least 1 find_arg'
        )
        SitePrism.logger.error("#{name} has come from an item with no locators.")
        define_method(name) { raise SitePrism::InvalidElementError }
      end

      def raise_if_build_time_block_supplied(parent_object, name, has_block, type)
        return unless has_block

        SitePrism.logger.debug("Type passed in: #{type}")
        SitePrism.logger.error("#{name} has been defined as a '#{type}' item in #{parent_object}. It does not accept build-time blocks.")
        raise SitePrism::UnsupportedBlockError
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

      def deduce_iframe_scope_find_args(args)
        warn_on_invalid_selector_input(args)
        case args[0]
        when Integer then [args[0]]
        when String  then [:css, args[0]]
        else args
        end
      end

      def deduce_iframe_element_find_args(args)
        warn_on_invalid_selector_input(args)
        case args[0]
        when Integer then "iframe:nth-of-type(#{args[0] + 1})"
        when String  then [:css, args[0]]
        else args
        end
      end

      def warn_on_invalid_selector_input(args)
        return unless looks_like_xpath?(args[0])

        SitePrism.logger.warn('The arguments passed in look like xpath. Check your locators.')
        SitePrism.logger.debug("Default locator strategy: #{Capybara.default_selector}")
      end

      def looks_like_xpath?(arg)
        arg.is_a?(String) && arg.start_with?('/', './')
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
