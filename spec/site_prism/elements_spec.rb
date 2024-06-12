# frozen_string_literal: true

describe 'Elements' do
  shared_examples 'a page' do
    describe '.elements' do
      it 'can be set on `SitePrism::Page`' do
        expect(SitePrism::Page).to respond_to(:elements)
      end

      it 'can be set on `SitePrism::Section`' do
        expect(SitePrism::Section).to respond_to(:elements)
      end

      it 'cannot be defined with a build time block' do
        expect { invalid_page }.to raise_error(SitePrism::UnsupportedBlockError)
      end
    end

    it 'returns an enumerable `Capybara::Result`' do
      expect(page.elements_one).to be_a(Capybara::Result)
    end
  end

  context 'with a Page defined using CSS locators' do
    let(:page) { CSSPage.new }
    let(:klass) { CSSPage }
    let(:invalid_page) do
      Class.new(CSSPage) do
        elements :fail, 'span.not-found' do
        end
      end
    end

    it_behaves_like 'a page'
  end

  context 'with a Page defined using XPath locators' do
    let(:page) { XPathPage.new }
    let(:klass) { XPathPage }
    let(:invalid_page) do
      Class.new(XPathPage) do
        elements :fail, '//span[@class="not-found"]' do
        end
      end
    end

    it_behaves_like 'a page'
  end
end
