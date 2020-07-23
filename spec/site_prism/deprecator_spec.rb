# frozen_string_literal: true

describe SitePrism::Deprecator do
  # This stops the stdout process leaking between tests
  before { wipe_logger! }

  describe '.deprecate' do
    it 'fires warning messages' do
      log_messages = capture_stdout do
        SitePrism.log_level = :WARN
        described_class.deprecate('old', 'new')
      end

      expect(lines(log_messages)).to eq 2
    end
  end

  describe '.soft_deprecate' do
    it 'fires warning messages' do
      log_messages = capture_stdout do
        SitePrism.log_level = :DEBUG
        described_class.soft_deprecate('old', 'reason', 'new')
      end

      expect(lines(log_messages)).to eq 4
    end
  end
end
