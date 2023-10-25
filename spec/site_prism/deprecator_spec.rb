# frozen_string_literal: true

describe SitePrism::Deprecator do
  # Stop the $stdout process leaking cross-tests
  before { wipe_logger! }

  describe '.deprecate' do
    it 'fires warning messages' do
      log_messages = capture_stdout do
        SitePrism.log_level = :WARN
        described_class.deprecate('old', 'new')
      end

      expect(lines(log_messages)).to eq(2)
    end
  end
end
