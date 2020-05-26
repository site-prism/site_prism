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

  describe '#start' do
    subject(:timer) { described_class.new(wait_time) }

    after do
      timer.stop
    end

    it 'starts the timer thread' do
      expect(Thread).to receive(:start)

      timer.start
    end

    it 'initially marks the timer as not done' do
      timer.start

      expect(timer).not_to be_done
    end

    it 'marks the timer as done after the specified wait time' do
      timer.start

      expect { sleep(0.15) }.to change(timer, :done?).from(false).to(true)
    end

    context 'with a wait time of 0' do
      let(:wait_time) { 0 }

      it 'does not start the timer thread' do
        expect(Thread).not_to receive(:start)

        timer.start
      end

      it 'immediately marks the timer as done' do
        timer.start

        expect(timer).to be_done
      end
    end
  end

  describe '#stop' do
    subject(:timer) { described_class.new(wait_time) }

    after do
      timer.stop
    end

    it 'stops the timer thread' do
      thread = timer.start
      expect { timer.stop }.to change(thread, :alive?).from(true).to(false)
    end

    it 'marks the timer as done' do
      timer.start
      timer.stop
      expect(timer).to be_done
    end

    context 'with a wait time of 0' do
      let(:wait_time) { 0 }

      it 'does not fail because of the missing timer thread' do
        timer.start
        expect { timer.stop }.not_to raise_error
      end

      it 'marks the timer as done' do
        timer.start
        timer.stop
        expect(timer).to be_done
      end
    end
  end
end
