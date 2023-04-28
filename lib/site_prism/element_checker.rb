# frozen_string_literal: true

module SitePrism
  #
  # [SitePrism::ElementChecker]
  #
  # This allows users to run `#all_there?` checks on an instance.
  #
  module ElementChecker
    # Runnable in the scope of any SitePrism::Page or Section.
    # Returns +true+ when "every item" that is being checked is
    # present within the current scope. See #elements_to_check
    # for how the definition of "every item" is derived.
    #
    # Example
    # @my_page.class.mapped_items
    #  {
    #    element => [:button_one, :button_two],
    #    elements => [:button_collection_one, :button_collection_two],
    #    section => [:filters],
    #    sections => [:search_result],
    #    iframe => []
    #  }
    # @my_page.all_there?
    # => true - If the items above are all present
    #
    # Note that #elements_to_check will check the hash of mapped_items
    #
    # When using the recursion parameter, one of two values is valid.
    #
    # Default: 'none' => Perform no recursion when calling #all_there?
    # Override: 'one' => Perform one recursive dive into all section/sections
    # items and call #all_there? on all of those items too.
    def all_there?(recursion: :none)
      SitePrism::AllThere::RecursionChecker.new(self).all_there?(recursion: recursion)
    end

    # Returns each element that is currently present inside the scope being tested
    #
    # @return [Array]
    def elements_present
      _mapped_items.select { |name| there?(name) }
    end

    # Returns each element that is not currently present inside the scope being tested
    #
    # @return [Array]
    def elements_missing
      elements_to_check.reject { |name| there?(name) }
    end

    private

    def elements_to_check
      if _expected_items
        SitePrism.logger.debug('Expected Items has been set.')
        _mapped_items.select { |name| _expected_items.include?(name) }
      else
        _mapped_items
      end
    end

    def _mapped_items
      self.class.mapped_items.values.flatten.uniq
    end

    def _expected_items
      self.class.expected_items
    end

    def there?(name)
      send("has_#{name}?")
    end
  end
end
