# frozen_string_literal: true

describe SitePrism do
  describe 'Elements' do
    shared_examples 'elements' do
      describe '.elements' do
        it 'can be set on `SitePrism::Page`' do
          expect(SitePrism::Page).to respond_to(:elements)
        end

        it 'can be set on `SitePrism::Section`' do
          expect(SitePrism::Section).to respond_to(:elements)
        end
      end

      it 'returns an enumerable `Capybara::Result`' do
        expect(page.elements_one).to be_a Capybara::Result
      end
    end

    context 'with a Page defined using CSS locators' do
      let(:page) { CSSPage.new }
      let(:klass) { CSSPage }

      it_behaves_like 'elements'
    end

    context 'with a Page defined using XPath locators' do
      let(:page) { XPathPage.new }
      let(:klass) { XPathPage }

      it_behaves_like 'elements'
    end
  end
end
