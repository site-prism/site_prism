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
    end

    private

    # Call `find` inside `to_capybara_node` context (Either Capybara::Session or Capybara::Node::Element)
    def _find(*find_args)
      kwargs = find_args.pop
      to_capybara_node.find(*find_args, **kwargs)
    end

    # Call `all` inside `to_capybara_node` context (Either Capybara::Session or Capybara::Node::Element)
    def _all(*find_args)
      kwargs = find_args.pop
      to_capybara_node.all(*find_args, **kwargs)
    end

    # Call `has_selector?` inside `to_capybara_node` context (Either Capybara::Session or Capybara::Node::Element)
    def element_exists?(*find_args)
      kwargs = find_args.pop
      to_capybara_node.has_selector?(*find_args, **kwargs)
    end

    # Call `has_no_selector?` inside `to_capybara_node` context (Either Capybara::Session or Capybara::Node::Element)
    def element_does_not_exist?(*find_args)
      kwargs = find_args.pop
      to_capybara_node.has_no_selector?(*find_args, **kwargs)
    end

    # Prevent users from calling methods with blocks when they shouldn't be.
    #
    # Example (Triggering error):
    #
    #       class MyPage
    #         element :sample, '.css-locator' do
    #           puts "This won't be output"
    #         end
    #       end
    #
    # At runtime this will generate a `SitePrism::UnsupportedBlockError`
    #
    # The only DSL keywords that can use blocks are :section and :iframe
    def raise_if_block(obj, name, has_block, type)
      return unless has_block

      SitePrism.logger.debug("Type passed in: #{type}")
      SitePrism.logger.warn('section / iFrame can only accept blocks.')
      SitePrism.logger.error("#{obj.class}##{name} does not accept blocks")

      raise SitePrism::UnsupportedBlockError
    end

    # Warn users from naming the elements starting with no_
    def warn_if_dsl_collision(obj, name)
      return unless name.to_s.start_with?('no_')

      SitePrism.logger.warn("#{obj.class}##{name} should not start with no_")
      SitePrism::Deprecator.deprecate('Using no_ prefix in DSL definition')
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

      # Creates an instance of a SitePrism Element - This will create several methods designed to
      # Locate the element -> @return [Capybara::Node::Element]
      # Check the elements presence or non-presence -> @return [Boolean]
      # Wait for the elements to be present or not -> @return [TrueClass, SitePrism::Error]
      # Validate certain properties about the element
      def element(name, *find_args)
        SitePrism::Deprecator.deprecate('Passing a block to :element') if block_given?
        build(:element, name, *find_args) do
          define_method(name) do |*runtime_args, &element_block|
            warn_if_dsl_collision(self, name)
            raise_if_block(self, name, !element_block.nil?, :element)
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
        SitePrism::Deprecator.deprecate('Passing a block to :elements') if block_given?
        build(:elements, name, *find_args) do
          define_method(name) do |*runtime_args, &element_block|
            warn_if_dsl_collision(self, name)
            raise_if_block(self, name, !element_block.nil?, :elements)
            _all(*merge_args(find_args, runtime_args))
          end
        end
      end

      # Sets the `expected_items` iVar on a class. This property is used in conjunction with
      # `all_there?` to provide a way of granularising the check made to only interrogate a sub-set
      # of DSL defined items
      def expected_elements(*elements)
        @expected_items = elements
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
            warn_if_dsl_collision(self, name)
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
          define_method(name) do |*runtime_args, &element_block|
            raise_if_block(self, name, !element_block.nil?, :sections)
            _all(*merge_args(find_args, runtime_args)).map do |element|
              section_class.new(self, element)
            end
          end
        end
      end

      def iframe(name, klass, *args)
        SitePrism.logger.debug('Block passed into iFrame construct at build time') if block_given?
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
      def mapped_items(legacy: true)
        return old_mapped_items if legacy

        new_mapped_items
      end

      private

      def old_mapped_items
        SitePrism::Deprecator.soft_deprecate(
          '.mapped_items on a class',
          'To allow easier recursion through the items in conjunction with #all_there?',
          '.mapped_items(legacy: false)'
        )
        @old_mapped_items ||= []
      end

      def new_mapped_items
        @new_mapped_items ||= { element: [], elements: [], section: [], sections: [], iframe: [] }
      end

      def build(type, name, *find_args)
        if find_args.empty?
          create_error_method(name)
        else
          map_item(type, name)
          yield
        end
        add_helper_methods(name, *find_args)
      end

      def map_item(type, name)
        old_mapped_items << { type => name }
        new_mapped_items[type] << name.to_sym
      end

      def add_helper_methods(name, *find_args)
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
        SitePrism.logger.error("#{name} has come from an item with no locators.")
        SitePrism::Deprecator.soft_deprecate(
          'DSL definition with no find_args',
          'All DSL elements should have find_args'
        )
        define_method(name) { raise SitePrism::InvalidElementError }
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
