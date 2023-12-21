# frozen_string_literal: true

module SitePrism
  # [SitePrism::Page]
  #
  # SitePrism Pages are the top level construct of the POM framework
  #
  # Instances of this class represent a full web page that can either be dynamically navigated to
  # through clicking buttons or filling in fields, or verbosely loaded by using the `#load` method
  #
  # All method calls made whilst on a page are scoped using `#to_capybara_node` which defaults to the
  # current Capybara session or the `@page` that has been loaded in-line
  class Page
    include Capybara::DSL
    include ElementChecker
    include Loadable
    include DSL

    class << self
      attr_reader :url

      # Sets and returns the specific url that will be loaded for a page object
      #
      # @return [String]
      def set_url(page_url)
        @url = page_url.to_s
      end

      # Sets and returns the specific url matcher that will be used to validate the page is loaded
      #
      # @return [Regexp]
      def set_url_matcher(page_url_matcher)
        @url_matcher = page_url_matcher
      end

      # The specific url matcher that is used to validate the page is loaded.
      # When one hasn't been previously set, use the url that was set as a direct Regexp exact matcher
      #
      # @return [Regexp || String]
      def url_matcher
        @url_matcher ||= url
      end
    end

    # This scopes our calls inside Page correctly to the `Capybara::Session`
    #
    # @return [Capybara::Node::Simple || Capybara::Session]
    def to_capybara_node
      (defined?(@page) && @page) || Capybara.current_session
    end

    # Loads the page.
    # @param expansion_or_html
    # @param block [&block] An optional block to run once the page is loaded.
    # The page will yield the block if defined.
    #
    # Executes the block, if given.
    # Runs load validations on the page, unless input is a string
    #
    # When calling #load, all the validations that are set will be ran in order
    def load(expansion_or_html = {}, &block)
      self.loaded = false
      SitePrism.logger.debug("Reset loaded state on #{self.class}.")

      return_yield = if expansion_or_html.is_a?(String)
                       load_html_string(expansion_or_html, &block)
                     else
                       load_html_website(expansion_or_html, &block)
                     end

      # Ensure that we represent that the page we loaded is now indeed loaded!
      # This ensures that future calls to #loaded? do not perform the
      # instance evaluations against all load validations procs another time.
      self.loaded = true

      SitePrism.logger.info("#{self.class} loaded.")
      # Return the yield from the block if there was one, otherwise return true
      return_yield || true
    end

    # Returns true if the page is displayed within the requisite time
    # Returns false if the page is not displayed within the requisite time
    #
    # @return [Boolean]
    def displayed?(*args)
      wait_until_displayed(*args)
    rescue SitePrism::TimeoutError
      false
    end

    # Wait until the page is displayed according to input arguments
    # If no url_matcher is provided we don't know how to determine if the page is displayed. So we return an error
    # Then we wait until the url matches the expected mappings
    #
    # @return [Boolean]
    def wait_until_displayed(*args)
      raise SitePrism::NoUrlMatcherForPageError unless url_matcher

      expected_mappings = args.last.is_a?(::Hash) ? args.pop : {}
      seconds = args&.first || Capybara.default_max_wait_time
      Waiter.wait_until_true(seconds) { url_matches?(expected_mappings) }
    end

    # Return the matching information of a page
    #
    # Return nil if the page is not displayed correctly
    # Return the regex matches if we have provided a regexp style url_matcher
    # Otherwise fall back to an addressable-style template of matches
    #
    # @return [Nil || MatchData || Hash]
    def url_matches(seconds = Capybara.default_max_wait_time)
      return unless displayed?(seconds)
      return regexp_backed_matches if url_matcher.is_a?(Regexp)

      template_backed_matches
    end

    # Returns the templated url from the set_url property defined during the page definition
    # Returns `nil` if there was not a property set (i.e. the page should not be directly loaded)
    #
    # @return [NilClass || String]
    def url(expansion = {})
      self.class.url && Addressable::Template.new(self.class.url).expand(expansion).to_s
    end

    # Returns the url_matcher property defined during the page definition
    #
    # @return [Regexp]
    def url_matcher
      self.class.url_matcher
    end

    # Returns true if the page is secure, otherwise returns false
    #
    # @return [Boolean]
    def secure?
      page.current_url.start_with?('https')
    end

    private

    def regexp_backed_matches
      url_matcher.match(page.current_url)
    end

    def template_backed_matches
      matcher_template.mappings(page.current_url)
    end

    def url_matches?(expected_mappings = {})
      if url_matcher.is_a?(Regexp)
        url_matches_by_regexp?
      elsif url_matcher.respond_to?(:to_str)
        url_matches_by_template?(expected_mappings)
      else
        raise SitePrism::InvalidUrlMatcherError
      end
    end

    def url_matches_by_regexp?
      !regexp_backed_matches.nil?
    end

    def url_matches_by_template?(expected_mappings)
      matcher_template.matches?(page.current_url, expected_mappings)
    end

    def matcher_template
      @matcher_template ||= AddressableUrlMatcher.new(url_matcher)
    end

    def load_html_string(string)
      SitePrism::Deprecator.deprecate('Using an input fragment (Loading partials using html strings).')
      @page = Capybara.string(string)
      yield to_capybara_node if block_given?
    end

    def load_html_website(html, &block)
      with_validations = html.delete(:with_validations) { true }
      expanded_url = url(html)
      raise SitePrism::NoUrlForPageError unless expanded_url

      visit expanded_url
      if with_validations
        when_loaded(&block)
      elsif block
        yield to_capybara_node
      end
    end
  end
end
