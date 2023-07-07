# frozen_string_literal: true

module SitePrism
  module DSL
    # [SitePrism::DSL::Methods]
    #
    # The meta-programmed methods for using SitePrism during runtime. This public DSL contains all the methods
    # you will use on `SitePrism::Page` or `SitePrism::Section` classes
    #
    module Methods
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

      private

      def raise_if_build_time_block_supplied(parent_object, name, has_block, type)
        return unless has_block

        SitePrism.logger.debug("Type passed in: #{type}")
        SitePrism.logger.error("#{name} has been defined as a '#{type}' item in #{parent_object}. It does not accept build-time blocks.")
        raise SitePrism::UnsupportedBlockError
      end

      def deduce_iframe_element_find_args(args)
        warn_on_invalid_selector_input(args)
        case args[0]
        when Integer then "iframe:nth-of-type(#{args[0] + 1})"
        when String  then [:css, args[0]]
        else args
        end
      end

      def deduce_iframe_scope_find_args(args)
        warn_on_invalid_selector_input(args)
        case args[0]
        when Integer then [args[0]]
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
    end
  end
end
