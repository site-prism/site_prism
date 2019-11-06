# frozen_string_literal: true

describe SitePrism::Section do
  subject(:page) { Page.new }

  class PluralSections < SitePrism::Section; end

  class PluralSectionsWithDefaults < SitePrism::Section
    set_default_search_arguments :css, '.section'
  end

  class Page < SitePrism::Page
    sections :plural_sections,               PluralSections, '.tim'
    sections :plural_sections_with_defaults, PluralSectionsWithDefaults
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
    expect(page.plural_sections).to be_an Array
  end

  context 'when using sections with default search arguments and without search arguments' do
    let(:search_arguments) { [:css, '.section'] }

    before do
      allow(page)
        .to receive(:_all)
        .with(*search_arguments, wait: 0)
        .and_return(%i[element1 element2])
    end

    it 'uses the `default_search_arguments` that have been set' do
      expect(described_class).to receive(:new).with(page, :element1).ordered
      expect(described_class).to receive(:new).with(page, :element2).ordered

      page.plural_sections_with_defaults
    end
  end
end
