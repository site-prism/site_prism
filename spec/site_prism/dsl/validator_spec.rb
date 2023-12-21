# frozen_string_literal: true

describe SitePrism::DSL::Validator do
  let(:validator) do
    Class.new do
      extend SitePrism::DSL::Validator
    end
  end

  describe '.name_invalid?' do
    context 'with a blacklisted prefix' do
      subject { validator.name_invalid?('no_we_are_not_allowed') }

      it { is_expected.to be true }
    end

    context 'with a blacklisted suffix' do
      subject { validator.name_invalid?('i_am_also_not_allowed_') }

      it { is_expected.to be true }
    end

    context 'with invalid characters' do
      subject { validator.name_invalid?('this_contains%20!invalidCH4RZ$') }

      it { is_expected.to be true }
    end

    context 'with a starting upper-case character' do
      subject { validator.name_invalid?('MUST_start_lowercase') }

      it { is_expected.to be true }
    end

    context 'with an invalid name' do
      subject { validator.name_invalid?('attributes') }

      it { is_expected.to be true }
    end

    context 'with a valid string' do
      subject { validator.name_invalid?('abcdef123_XYZ') }

      it { is_expected.to be false }
    end
  end

  context 'when disabled' do
    let(:invalid_page) do
      Class.new(SitePrism::Page) do
        element :no_im_not_valid, '.foo'
      end
    end

    describe '.name_invalid?' do
      before { allow(SitePrism).to receive(:dsl_validation_disabled).and_return(true) }

      it 'is never called when invalid DSL names are permitted' do
        expect(invalid_page).not_to receive(:name_invalid?)

        invalid_page
      end
    end
  end
end
