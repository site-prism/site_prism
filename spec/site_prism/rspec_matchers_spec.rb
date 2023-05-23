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

  around do |example|
    app = Capybara.app

    begin
      Capybara.app = ->(_env) { [200, {}, <<~HTML.gsub(/^\s+/, '')] }
        <html>
          <head></head>
          <body>
            <a href="#" class="foo">foo-link</a>
            <table id="my-table">a table here</table>
          </body>
        </html>
      HTML

      example.run
    ensure
      Capybara.app = app
    end
  end

  it 'works with Ruby 3 keyword arguments for links' do
    instance.load

    expect(instance).to have_link(text: 'foo-link', class: 'foo')
  end

  it 'works with Ruby 3 keyword arguments for tables' do
    instance.load

    expect(instance).to have_table(text: 'a table here', id: 'my-table')
  end
end
