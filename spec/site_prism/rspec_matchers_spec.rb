# frozen_string_literal: true

describe SitePrism::RSpecMatchers do
  let(:page) do
    Class.new(SitePrism::Page) do
      set_url '/'

      element :link, 'a'
      element :table, 'table'
    end
  end
  let(:instance) { page.new }

  it 'works with Ruby 3 keyword arguments for links' do
    instance.load

    expect(instance).to have_link(text: 'foo-link', class: 'foo')
  end

  it 'works with Ruby 3 keyword arguments for tables' do
    instance.load

    expect(instance).to have_table(text: 'a table here', id: 'my-table')
  end
end
