# frozen_string_literal: true

describe SitePrism::Timer do
  let(:wait_time) { 0.1 }

  describe '#initialize' do
    subject(:timer) { described_class.new(wait_time) }

    it 'sets the wait time' do
      expect(timer.wait_time).to eq(0.1)
    end

    it 'initially marks the timer as not done' do
      expect(timer).not_to be_done
    end
  end

  describe '.run' do
    subject(:timer) { described_class.new(wait_time) }

    it 'yields the timer to the block' do
      yielded_value = nil
      timer.run { |t| yielded_value = t }

      expect(yielded_value).to eq(timer)
    end

    it 'starts the timer within the block and stops it afterwards' do
      states = []
      states << timer.done?
      timer.run { |t| states << t.done? }
      states << timer.done?

      expect(states).to contain_exactly(false, false, true)
    end

    context 'with an exception within the block' do
      it 'sets the state to done without rescuing the exception' do
        expect { timer.run { raise 'test error' } }
          .to raise_error('test error')
          .and change(timer, :done?).from(false).to(true)
      end
    end
  end
end
