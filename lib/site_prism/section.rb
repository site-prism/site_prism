# frozen_string_literal: true

module SitePrism
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

    # This allows us to return anything thats passed in as a block to the section at
    # creation time, so that an anonymous section or such-like will have the extra methods
    def within
      Capybara.within(root_element) { yield(self) }
    end

    # This was the old API-style of delegating through the Capybara.page call and over-loading
    # the method so we always went through our correct `root_element`
    def page
      SitePrism::Deprecator.deprecate('Using page inside section')
      return root_element if root_element

      SitePrism.logger.warn('Root Element not found; Falling back to Capybara.current_session')
      capybara_session
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
