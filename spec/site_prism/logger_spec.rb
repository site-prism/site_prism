# frozen_string_literal: true

describe SitePrism::Logger do
  describe '#create' do
    subject(:logger) { described_class.new.create }

    it { is_expected.to be_a Logger }

    it 'has a default name' do
      expect(logger.progname).to eq('SitePrism')
    end

    it 'has a default logging level' do
      expect(logger.level).to eq(5)
    end
  end
end
