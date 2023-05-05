# frozen_string_literal: true

module SitePrism
  module DSL
    # [SitePrism::DSL::D_S_L]
    #
    # This is a newly migrated experimental way of partitioning the SitePrism internal DSL
    #
    # It is currently completely switched off and disabled / untested, and will remain this way for all of v4
    #
    # ~~~~~~~~~~~~~ PREVIOUS DOCUMENTATION ~~~~~~~~~~~~~
    #
    # [SitePrism::DSL::ClassMethods]
    # This exposes all of the DSL definitions users will use when generating
    # their POM classes.
    #
    # Many of these methods will be used in-line to allow users to generate a multitude of
    # methods and locators for finding elements / sections on a page or section of a page
    module D_S_L
      attr_reader :expected_items

      def self.included(klass)
        SitePrism.logger.error('The new experimental DSL partitioning has been required. Code will now crash!')
        raise SitePrismError
      end

      class << self
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
      end
    end
  end
end
