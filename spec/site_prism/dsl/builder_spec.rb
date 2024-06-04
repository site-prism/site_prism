# frozen_string_literal: true

describe SitePrism::DSL::Builder do
  let(:invalid_dsl_prefix) do
    Class.new(SitePrism::Page) do
      element :no_im_not_valid, '.foo'
    end
  end
  let(:invalid_dsl_suffix) do
    Class.new(SitePrism::Page) do
      element :no_im_not_valid_, '.foo'
    end
  end
  let(:invalid_dsl_characters) do
    Class.new(SitePrism::Page) do
      element :no_im_not_perM1tEd_anywhere, '.foo'
    end
  end
  let(:blacklisted_name) do
    Class.new(SitePrism::Page) do
      element :attributes, '.foo'
    end
  end

  it 'does not build pages with invalid DSL prefixes' do
    expect { invalid_dsl_prefix }.to raise_error(SitePrism::InvalidDSLNameError)
  end

  it 'does not build pages with invalid DSL suffixes' do
    expect { invalid_dsl_suffix }.to raise_error(SitePrism::InvalidDSLNameError)
  end

  it 'does not build pages with names that are not snake_cased' do
    expect { invalid_dsl_characters }.to raise_error(SitePrism::InvalidDSLNameError)
  end

  it 'does not build pages with blacklisted DSL names' do
    expect { blacklisted_name }.to raise_error(SitePrism::InvalidDSLNameError)
  end
end
