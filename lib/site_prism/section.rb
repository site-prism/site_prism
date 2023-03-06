# frozen_string_literal: true

module SitePrism
  # [SitePrism::Section]
  #
  # SitePrism Sections are the mid level construct of the POM framework
  #
  # Instances of this class represent a a part of a web page that can either sit inside a SitePrism::Page
  # or sit inside another N sections, which then eventually will sit inside a page
  #
  # All method calls made whilst on a page are scoped using `#to_capybara_node` which will be represented by
  # the current `#root_element`. This is the locator for the section itself and is a mandatory argument
  class Section
    include ElementChecker
    include Loadable
    include DSL
    extend Forwardable

    attr_reader :root_element, :parent

    class << self
      def set_default_search_arguments(*args)
        @default_search_arguments = args
      end

      def default_search_arguments
        return @default_search_arguments if @default_search_arguments

        superclass.respond_to?(:default_search_arguments) && superclass.default_search_arguments
      end

      private

      def root_element_methods
        ::Capybara::Session::NODE_METHODS + %i[native visible?]
      end

      def session_methods
        ::Capybara::Session::DSL_METHODS - root_element_methods
      end
    end

    def initialize(parent, root_element, &block)
      @parent = parent
      @root_element = root_element
      within(&block) if block
    end

    # Send all root_element methods through `#root_element`
    # NB: This requires a method called `#to_capybara_node` being created and
    # then set to this value (Capybara agnostic API)
    root_element_methods.each do |method|
      def_delegators :root_element, method
    end

    # Send all methods that previously acted on the `#page` method that existed previously
    # through to the same location - But directly as `Capybara.current_session`
    session_methods.each do |method|
      def_delegators :capybara_session, method
    end

    # This scopes our calls inside Section correctly to the `Capybara::Node::Element`
    def to_capybara_node
      root_element
    end

    # This allows us to return anything that's passed in as a block to the section at
    # creation time, so that an anonymous section or such-like will have the extra methods
    #
    # This can also be used manually at runtime to allow people to abbreviate their calls
    def within
      Capybara.within(root_element) { yield(self) }
    end

    def capybara_session
      Capybara.current_session
    end

    def parent_page
      candidate = parent
      candidate = candidate.parent until candidate.is_a?(SitePrism::Page)
      candidate
    end
  end
end
