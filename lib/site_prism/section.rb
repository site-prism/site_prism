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

    ROOT_ELEMENT_METHODS = ::Capybara::Session::NODE_METHODS + [:native]
    SESSION_METHODS = ::Capybara::Session::DSL_METHODS - ::Capybara::Session::NODE_METHODS

    private_constant :ROOT_ELEMENT_METHODS, :SESSION_METHODS

    ROOT_ELEMENT_METHODS.each do |method|
      def_delegators :root_element, method
    end

    SESSION_METHODS.each do |method|
      def_delegators :capybara_session, method
    end

    def to_capybara_node
      @root_element
    end

    def within
      Capybara.within(@root_element) { yield(self) }
    end

    # This is no longer a necessary method should probably be deprecated/removed
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
