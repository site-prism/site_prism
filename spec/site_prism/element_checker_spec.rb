# frozen_string_literal: true

describe SitePrism::ElementChecker do
  let!(:section_locator) { instance_double(Capybara::Node::Element) }
  let(:expected) { %i[element_one element_two element_three elements_one section_one sections_one iframe] }

  shared_examples 'a page' do
    describe '#all_there?' do
      subject { page.all_there? }

      let(:recursion_class) { SitePrism::AllThere::RecursionChecker }

      # TODO: Remove this once all_there has had a bugfix release to handle missing elements
      before do
        allow(page).to receive(:section_one).and_return(section)
      end

      it 'delegates to the `AllThere` gem' do
        expect(recursion_class).to receive(:new).with(page).and_call_original

        subject
      end
    end

    describe '#elements_missing' do
      subject { page.elements_missing }

      let(:not_expected) { page.class.mapped_items.values.flatten - expected_items }

      it 'calls #there? on all expected elements that are mapped' do
        page.load
        
        expected.each do | item|
          expect(page).to receive(:there?).with(item).once
        end

        subject
      end

      it 'does not calls #there? for elements not defined as expected' do
        page.load

        not_expected.each do | item|
          expect(page).not_to receive(:there?).with(item)
        end

        subject
      end

      it 'returns missing elements' do
        page.load

        # TODO: Alter the expected elements to have one that IS missing
        expect(subject).to eq([])
      end
    end

    describe '#elements_present' do
      it 'lists the SitePrism objects that are present on the page' do
        page.load

        expect(page.elements_present).to eq(expected)
      end
    end
  end

  context 'with a Page defined using CSS locators' do
    let(:page) { CSSPage.new }
    let(:section) { CSSSection.new(page, section_locator) }
    let(:expected_items) { CSSPage.expected_items }

    it_behaves_like 'a page'
  end

  context 'with a Page defined using XPath locators' do
    let(:page) { XPathPage.new }
    let(:section) { XPathSection.new(page, section_locator) }
    let(:expected_items) { XPathPage.expected_items }

    it_behaves_like 'a page'
  end
end
