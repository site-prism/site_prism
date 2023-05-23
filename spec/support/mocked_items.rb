# frozen_string_literal: true

module SitePrism
  module Support
    module MockedItems
      module_function

      def present_on_page
        %i[element_one elements_one section_one sections_one element_three]
      end
    end
  end
end
