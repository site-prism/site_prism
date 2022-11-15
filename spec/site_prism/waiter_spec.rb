# frozen_string_literal: true

describe SitePrism::Waiter do
  describe '.wait_until_true' do
    let(:default_duration) { 0.1 }
    let(:default_timeout) { 0.1 }

    def execute_waiter(timeout = default_timeout, duration = default_duration, &block)
      described_class.wait_until_true(timeout, duration, &block)
    end

    it 'throws a Timeout exception if the block does not become true' do
      expect { execute_waiter(default_timeout) { false } }
        .to raise_error(SitePrism::TimeoutError)
        .with_message(/#{default_timeout}/)
    end

    it 'returns true if block is truthy' do
      expect(execute_waiter { true }).to be true
    end

    context 'with a custom timeout' do
      let(:custom_timeout) { 0.18 }

      it 'alters the error message' do
        expect { execute_waiter(custom_timeout) { false } }
          .to raise_error(SitePrism::TimeoutError)
          .with_message(/#{custom_timeout}/)
      end
    end

    context 'with a custom sleep_duration' do
      let(:long_sleep_duration) { 0.5 }
      let(:short_sleep_duration) { 0.01 }

      it 'when setting sleep_duration > timeout, error raise and yield execute 2 times' do
        count = 0
        swallow_timeout do
          execute_waiter(default_timeout, long_sleep_duration) { false.tap { count += 1 } }
        end
        expect(count).to eq(2)
      end

      it 'when setting sleep_duration < timeout, error raise and yield execute many times' do
        count = 0
        swallow_timeout do
          execute_waiter(default_timeout, short_sleep_duration) { false.tap { count += 1 } }
        end
        expect(count).to be >= 10
      end
    end
  end
end
