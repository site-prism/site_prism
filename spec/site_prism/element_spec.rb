# frozen_string_literal: true

describe 'Element' do
  # Stop the $stdout process leaking cross-tests
  before { wipe_logger! }

  shared_examples 'an element' do
    describe '.element' do
      it 'can be set on `SitePrism::Page`' do
        expect(SitePrism::Page).to respond_to(:element)
      end

      it 'can be set on `SitePrism::Section`' do
        expect(SitePrism::Section).to respond_to(:element)
      end

      it 'cannot be defined with a build time block' do
        expect { invalid_page }.to raise_error(SitePrism::UnsupportedBlockError)
      end
    end

    it { is_expected.to respond_to(:element_one) }
    it { is_expected.to respond_to(:has_element_one?) }
    it { is_expected.to respond_to(:has_no_element_one?) }
    it { is_expected.to respond_to(:wait_until_element_one_visible) }
    it { is_expected.to respond_to(:wait_until_element_one_invisible) }

    it 'supports rspec existence matchers' do
      page.load

      expect(page).to have_element_one
    end

    it 'calls the SitePrism matcher when using an rspec negated existence matcher' do
      page.load

      expect(page).to receive(:has_no_missing_elements_two?).once.and_call_original

      expect(page).not_to have_missing_elements_two
    end

    context 'when other classes have the overlapping methods defined' do
      subject(:page) { anonymous_test_class.new }

      let(:anonymous_test_class) do
        Class.new do
          def has_element_one?
            true
          end

          def has_element_two?
            false
          end
        end
      end

      it 'does not break the normal existence matcher behaviour' do
        expect(page).to have_element_one
      end

      it 'does not break the SitePrism defined negation matcher behaviour' do
        expect(page).not_to have_element_two
      end
    end

    describe '#elements_present' do
      it 'only lists the SitePrism objects that are present on the page' do
        page.load

        expect(page.elements_present).to eq(klass.expected_items - [:missing_element])
      end
    end

    describe '.expected_elements' do
      it 'automatically sets the value of expected_items' do
        expect(klass.expected_items).not_to be_empty
      end
    end
  end

  context 'with a Page defined using CSS locators' do
    subject { page }

    let(:page) { CSSPage.new }
    let(:klass) { CSSPage }
    let(:invalid_page) do
      Class.new(CSSPage) do
        element :fail, 'span.not-found' do
        end
      end
    end

    it_behaves_like 'an element'
  end

  context 'with a Page defined using XPath locators' do
    subject { page }

    let(:page) { XPathPage.new }
    let(:klass) { XPathPage }
    let(:invalid_page) do
      Class.new(XPathPage) do
        element :fail, '//span[@class="not-found"]' do
        end
      end
    end

    it_behaves_like 'an element'
  end
end
