# frozen_string_literal: true

describe SitePrism::RspecMatchers do
  include Capybara::DSL

  around do |example|
    app = Capybara.app

    begin
      Capybara.app = ->(_env) { [200, {}, <<-HTML] }
        <html><head></head><body><a href="#">a</a><table id="my-table"></table></body></html>
      HTML

      example.run
    ensure
      Capybara.app = app
    end
  end

  it 'works with Ruby 3 keyword arguments for links' do
    visit '/'

    expect(page).to have_link('a', href: '#')
  end

  it 'works with Ruby 3 keyword arguments for tables' do
    visit '/'

    expect(page).to have_table('my-table', rows: [])
  end
end
