# frozen_string_literal: true

require 'site_prism/loadable'

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

    ::Capybara::Session::NODE_METHODS.each do |method|
      class_eval <<~METHOD, __FILE__, __LINE__ + 1
        def #{method}(...)
          @root_element.method("#{method}").call(...)
        end
      METHOD
    end

    (::Capybara::Session::DSL_METHODS - ::Capybara::Session::NODE_METHODS).each do |method|
      class_eval <<~METHOD, __FILE__, __LINE__ + 1
        def #{method}(...)
          @parent.method("#{method}").call(...)
        end
      METHOD
    end

    def to_capybara_node
      @root_element
    end

    def within
      Capybara.within(@root_element) { yield(self) }
    end

    # This is no longer a necessary method should probably be deprecated/removed
    def page
      return root_element if root_element

      SitePrism.logger.warn('Root Element not found; Falling back to Capybara.current_session')
      Capybara.current_session
    end

    def visible?
      @root_element.visible?
    end

    def_delegators :capybara_session,
                   :execute_script,
                   :evaluate_script,
                   :within_frame

    def capybara_session
      Capybara.current_session
    end

    def parent_page
      candidate = parent
      candidate = candidate.parent until candidate.is_a?(SitePrism::Page)
      candidate
    end

    def native
      root_element.native
    end

    private

    def _find(*find_args)
      kwargs = find_args.pop
      page.find(*find_args, **kwargs)
    end

    def _all(*find_args)
      kwargs = find_args.pop
      page.all(*find_args, **kwargs)
    end

    def element_exists?(*find_args)
      kwargs = find_args.pop
      page.has_selector?(*find_args, **kwargs)
    end

    def element_does_not_exist?(*find_args)
      kwargs = find_args.pop
      page.has_no_selector?(*find_args, **kwargs)
    end
  end
end
