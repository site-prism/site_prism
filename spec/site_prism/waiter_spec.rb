# frozen_string_literal: true

describe SitePrism::Waiter do
  describe '.wait_until_true' do
    it 'throws a Timeout exception if the block does not become true' do
      allow(Capybara).to receive(:default_max_wait_time).and_return(0.1)

      expect { described_class.wait_until_true { false } }
        .to raise_error(SitePrism::TimeoutError)
        .with_message(/0.1/)
    end

    it 'returns true if block returns true' do
      expect(described_class.wait_until_true { true }).to be true
    end

    context 'with a custom timeout' do
      let(:timeout) { 0.2 }

      it 'alters the error message' do
        expect { described_class.wait_until_true(timeout) { false } }
          .to raise_error(SitePrism::TimeoutError)
          .with_message(/#{timeout}/)
      end

      it 'waits the according amount of time' do
        start_time = Time.now

        expect { described_class.wait_until_true(timeout) { false } }
          .to raise_error(SitePrism::TimeoutError)

        duration = Time.now - start_time

        expect(duration).to be_within(0.1).of(timeout)
      end
    end
  end
end
