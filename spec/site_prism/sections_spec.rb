# frozen_string_literal: true

describe SitePrism::Section do
  let(:page_instance) { page.new }
  let(:page) do
    plural_sections = Class.new(described_class)
    plural_sections_with_defaults =
      Class.new(described_class) do
        set_default_search_arguments :css, '.section'
      end

    Class.new(SitePrism::Page) do
      sections :plural_sections, plural_sections, '.tim'
      sections :plural_sections_with_defaults, plural_sections_with_defaults
    end
  end

  describe '.sections' do
    it 'can be set on `SitePrism::Page`' do
      expect(SitePrism::Page).to respond_to(:sections)
    end

    it 'can be set on `SitePrism::Section`' do
      expect(described_class).to respond_to(:sections)
    end
  end

  it 'returns an enumerable Array' do
    expect(page_instance.plural_sections).to be_an Array
  end

  context 'when using sections with default search arguments set but no defined search arguments' do
    let(:search_arguments) { [:css, '.section'] }

    before do
      allow(page_instance)
        .to receive(:_all)
        .with(*search_arguments, wait: 0)
        .and_return(%i[element1 element2])
    end

    it 'uses the `default_search_arguments` that have been set' do
      expect(described_class).to receive(:new).twice

      page_instance.plural_sections_with_defaults
    end
  end
end
