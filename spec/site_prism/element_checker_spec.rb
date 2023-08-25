# frozen_string_literal: true

describe SitePrism::ElementChecker do
  shared_examples 'a page' do
    before { page.load }

    describe '#all_there?' do
      it 'delegates to the `AllThere` gem' do
        expect(SitePrism::AllThere::RecursionChecker).to receive(:new).with(page).and_call_original

        page.all_there?
      end
    end

    describe '#elements_missing' do
      subject { page.elements_missing }

      let(:not_expected) { page.class.mapped_items.values.flatten - expected_items }

      it 'calls #there? on all expected elements that are mapped' do
        expected_items.each do |item|
          expect(page).to receive(:there?).with(item).once
        end

        subject
      end

      it 'does not calls #there? for elements not defined as expected' do
        not_expected.each do |item|
          expect(page).not_to receive(:there?).with(item)
        end

        subject
      end

      it 'returns missing elements' do
        expect(subject).to eq([:missing_element])
      end
    end

    describe '#elements_present' do
      it 'lists the SitePrism objects that are present on the page' do
        expect(page.elements_present).to eq(expected_items - [:missing_element])
      end
    end
  end

  context 'with a Page defined using CSS locators' do
    let(:page) { CSSPage.new }
    let(:expected_items) { CSSPage.expected_items }

    it_behaves_like 'a page'
  end

  context 'with a Page defined using XPath locators' do
    let(:page) { XPathPage.new }
    let(:expected_items) { XPathPage.expected_items }

    it_behaves_like 'a page'
  end
end
