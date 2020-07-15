# frozen_string_literal: true

describe SitePrism do
  describe 'Element' do
    # This stops the stdout process leaking between tests
    before { wipe_logger! }

    let(:expected_elements) { SitePrism::SpecHelper.present_on_page }

    shared_examples 'an element' do
      describe '.element' do
        it 'can be set on `SitePrism::Page`' do
          expect(SitePrism::Page).to respond_to(:element)
        end

        it 'can be set on `SitePrism::Section`' do
          expect(SitePrism::Section).to respond_to(:element)
        end
      end

      it { is_expected.to respond_to(:element_one) }
      it { is_expected.to respond_to(:has_element_one?) }
      it { is_expected.to respond_to(:has_no_element_one?) }
      it { is_expected.to respond_to(:wait_until_element_one_visible) }
      it { is_expected.to respond_to(:wait_until_element_one_invisible) }

      it 'supports rspec existence matchers' do
        expect(subject).to have_element_one
      end

      it 'calls the SitePrism matcher when using an rspec negated existence matcher' do
        allow(subject).to receive(:has_no_element_two?).once.and_call_original

        expect(subject).not_to have_element_two
      end

      context 'when other classes have the overlapping methods defined' do
        subject { anonymous_test_class.new }

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
          expect(subject).to have_element_one
        end

        it 'does not break the SitePrism defined negation matcher behaviour' do
          expect(subject).not_to have_element_two
        end
      end

      it 'raises a warning when the name starts with no_' do
        log_messages = capture_stdout do
          described_class.log_level = :WARN
          subject.no_such_element
        end
        expect(lines(log_messages)).to eq 3
      end

      describe '#elements_present' do
        it 'only lists the SitePrism objects that are present on the page' do
          expect(page.elements_present.sort).to eq(expected_elements.sort)
        end
      end

      describe '.expected_elements' do
        it 'sets the value of expected_items' do
          expect(klass.expected_items)
            .to eq(%i[element_one elements_one section_one sections_one])
        end
      end
    end

    context 'with a Page defined using CSS locators' do
      subject { page }

      let(:page) { CSSPage.new }
      let(:klass) { CSSPage }
      let(:element) { instance_double('Capybara::Node::Element') }

      before do
        allow(page)
          .to receive(:element)
          .with(:no_such_element, 'a.b c.d')
          .and_call_original
        allow(page)
          .to receive(:_find)
          .with('a.b c.d', wait: 0)
          .and_return(element)
      end

      it_behaves_like 'an element'
    end

    context 'with a Page defined using XPath locators' do
      subject { page }

      let(:page) { XPathPage.new }
      let(:klass) { XPathPage }
      let(:element) { instance_double('Capybara::Node::Element') }

      before do
        allow(page)
          .to receive(:element)
          .with(:no_such_element, '//a[@class="b"]//c[@class="d"]')
          .and_call_original
        allow(page)
          .to receive(:_find)
          .with('//a[@class="b"]//c[@class="d"]', wait: 0)
          .and_return(element)
      end

      it_behaves_like 'an element'
    end
  end
end
