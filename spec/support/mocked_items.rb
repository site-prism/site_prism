module SitePrism
  module Support
    module MockedItems
      module_function

      def present_on_page
        %i[element_one elements_one section_one sections_one element_three]
      end

      def present_on_section
        %i[inner_element_one inner_element_two iframe]
      end
    end
  end
end
