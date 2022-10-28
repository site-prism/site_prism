# frozen_string_literal: true

describe SitePrism::DSLValidator do
  let(:validator) do
    Class.new do
      extend SitePrism::DSLValidator
    end
  end

  describe '.invalid?' do
    context 'with a blacklisted prefix' do
      subject { validator.invalid?('no_we_are_not_allowed') }

      it { is_expected.to be true }
    end

    context 'with a blacklisted suffix' do
      subject { validator.invalid?('i_am_also_not_allowed_') }

      it { is_expected.to be true }
    end

    context 'with invalid characters' do
      subject { validator.invalid?('this_contains%20!invalidCH4RZ$') }

      it { is_expected.to be true }
    end

    context 'with a starting upper-case character' do
      subject { validator.invalid?('MUST_start_lowercase') }

      it { is_expected.to be true }
    end

    context 'with an invalid name' do
      subject { validator.invalid?('attributes') }

      it { is_expected.to be true }
    end

    context 'with a valid string' do
      subject { validator.invalid?('abcdef123_XYZ') }

      it { is_expected.to be false }
    end
  end
end
