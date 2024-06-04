# frozen_string_literal: true

describe SitePrism::DSL::Builder do
  subject(:invalid_page) do
    Class.new(SitePrism::Page) do
      element :no_im_not_valid, '.foo'
    end
  end

  it 'does not build pages with invalid DSL names' do
    expect { invalid_page }.to raise_error(SitePrism::InvalidDSLNameError)
  end
end
