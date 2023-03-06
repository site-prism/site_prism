# frozen_string_literal: true

describe SitePrism::ElementChecker do
  let!(:section_locator) { instance_double(Capybara::Node::Element) }

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

      let(:present) { expected_items[1..-1] }
      let(:missing) { expected_items[0] }
      let(:not_expected) { page.class.mapped_items.values.flatten - expected_items }

      it 'calls #there? for missing elements' do
        present.each { |name| allow(page).to receive(:there?).with(name).once.and_call_original }
        expect(page).to receive(:there?).with(missing).once.and_return(false)

        subject
      end

      it 'calls #there? for present elements' do
        allow(page).to receive(:there?).with(missing).once.and_return(false)
        present[1..-1].each { |name| allow(page).to receive(:there?).with(name).once }
        expect(page).to receive(:there?).with(present[0]).once.and_return(true)

        subject
      end

      it 'does not calls #there? for elements not defined as expected' do
        expect(page).not_to receive(:there?).with(array_including(*not_expected))

        subject
      end

      it 'returns missing elements' do
        allow(page).to receive(:there?).with(missing).once.and_return(false)
        present.each do |name|
          allow(page).to receive(:there?).with(name).once.and_call_original
        end

        expect(subject).to match_array(missing)
      end
    end

    describe '#elements_present' do
      it 'lists the SitePrism objects that are present on the page' do
        expect(page.elements_present)
          .to eq(%i[element_one element_three elements_one section_one sections_one])
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
