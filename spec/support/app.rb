# frozen_string_literal: true

module SitePrism
  module Support
    class App
      def call(_env)
        [200, {}, [html]]
      end
      
      def html
        <<~HTML.gsub(/^\s+/, '')
          <html>
            <head></head>
            <body>
              <a href="#" class="foo">foo-link</a>
              <table id="my-table">a table here</table>
              <span class="locator">
                <div class="one">
                  Inner element one text
                </div>
                <div class="two">
                  Inner element two text
                </div>
                <iframe class="inner-iframe" name="the_inner_iframe"></iframe>
              </span>
            </body>
          </html>
        HTML
      end
    end
  end
end
