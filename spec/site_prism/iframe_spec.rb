# frozen_string_literal: true

describe SitePrism do
  describe 'iFrame' do
    let!(:locator) { instance_double('Capybara::Node::Element') }
    let(:frame_instance) { frame_class.new }

    shared_examples 'iFrame' do
      before { allow(frame_class).to receive(:new).and_return(frame_instance) }

      it 'cannot be called out of block context' do
        expect { page.iframe }.to raise_error(SitePrism::MissingBlockError)
      end

      describe 'A Page with an iFrame contained within' do
        it 'uses #within_frame delegated through Capybara.current_session' do
          allow(frame_instance)
            .to receive(:_find).with(*element_caller_args).and_return(locator)

          expect(Capybara.current_session)
            .to receive(:within_frame).with(*frame_caller_args).and_yield

          page.iframe(&:element_one)
        end

        it 'passes the caller arg to the frame instance to then perform the location check' do
          allow(Capybara.current_session)
            .to receive(:within_frame).with(*frame_caller_args).and_yield

          expect(frame_instance)
            .to receive(:_find).with(*element_caller_args).and_return(locator)

          page.iframe(&:element_one)
        end
      end

      describe 'A Section with an iFrame contained within' do
        before do
          allow(page).to receive(:_find).with(*section_locator).and_return(locator)
        end

        it 'uses #within_frame delegated through Capybara.current_session' do
          allow(frame_instance)
            .to receive(:_find).with(*element_caller_args).and_return(locator)

          expect(Capybara.current_session)
            .to receive(:within_frame).with(*frame_caller_args).and_yield

          page.section_one.iframe(&:element_one)
        end

        it 'passes the caller arg to the frame instance to then perform the location check' do
          allow(Capybara.current_session)
            .to receive(:within_frame).with(*frame_caller_args).and_yield

          expect(frame_instance)
            .to receive(:_find).with(*element_caller_args).and_return(locator)

          page.section_one.iframe(&:element_one)
        end
      end
    end

    describe '#warn_on_invalid_selector_input' do
      let(:invalid_class) do
        Class.new(SitePrism::Page) do
          iframe :bad_iframe_reference, XPathIFrame, '//xpath'
        end
      end

      before { wipe_logger! }

      it 'will throw a warning when creating an iFrame with an invalid locator' do
        log_messages = capture_stdout do
          described_class.log_level = :WARN
          invalid_class
        end

        expect(lines(log_messages)).to eq 2
      end
    end

    context 'with css elements' do
      let(:page) { CSSPage.new }
      let(:klass) { CSSPage }
      let(:frame_caller_args) { [:css, '.iframe'] }
      let(:frame_class) { CSSIFrame }
      let(:section_locator) { ['span.locator', { wait: 0 }] }
      let(:element_caller_args) { ['.some_element', { wait: 0 }] }

      it_behaves_like 'iFrame'
    end

    context 'with xpath elements' do
      let(:page) { XPathPage.new }
      let(:klass) { XPathPage }
      let(:frame_caller_args) { [:xpath, '//*[@class="iframe"]'] }
      let(:frame_class) { XPathIFrame }
      let(:section_locator) { [:xpath, '//span[@class="locator"]', { wait: 0 }] }
      let(:element_caller_args) { [:xpath, '//[@class="some_element"]', { wait: 0 }] }

      it_behaves_like 'iFrame'
    end
  end
end
