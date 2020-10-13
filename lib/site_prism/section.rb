# frozen_string_literal: true

module SitePrism
  class Section
    include ElementChecker
    include Loadable
    include DSL
    extend Forwardable

    attr_reader :root_element, :parent

    def self.set_default_search_arguments(*args)
      @default_search_arguments = args
    end

    def self.default_search_arguments
      @default_search_arguments ||
        (
          superclass.respond_to?(:default_search_arguments) &&
          superclass.default_search_arguments
        ) ||
        nil
    end

    def initialize(parent, root_element, &block)
      @parent = parent
      @root_element = root_element
      within(&block) if block_given?
    end

    private

    def root_element_methods
      ::Capybara::Session::NODE_METHODS + [:native]
    end

    def session_methods
      ::Capybara::Session::DSL_METHODS - ::Capybara::Session::NODE_METHODS
    end

    ROOT_ELEMENT_METHODS = ::Capybara::Session::NODE_METHODS + [:native]
    SESSION_METHODS = ::Capybara::Session::DSL_METHODS - ::Capybara::Session::NODE_METHODS

    private_constant :ROOT_ELEMENT_METHODS, :SESSION_METHODS

    public

    root_element_methods.each do |method|
      def_delegators :root_element, method
    end

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
      Capybara.within(@root_element) { yield(self) }
    end

    # This was the old API-style of delegating through the Capybara.page call and over-loading
    # the method so we always went through our correct `root_element`
    def page
      SitePrism::Deprecator.deprecate('Using page inside section')
      return root_element if root_element

      SitePrism.logger.warn('Root Element not found; Falling back to Capybara.current_session')
      capybara_session
    end

    def visible?
      @root_element.visible?
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
