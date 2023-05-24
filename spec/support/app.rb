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
              <span class="alert-success">
              // CSSPage/XPathPage
              <div class="present-wrapper">
                <div class="valid-one">
                  Regular element one text
                </div>
                <div class="valid-two">
                  Regular element one text
                </div>
              </div>
              // CSSSection/XPathSection
              <span class="locator">
                <span class="one">
                  Inner element one text
                </span>
                <span class="two">
                  Inner element two text
                </span>
                <iframe class="iframe" name="the_inner_iframe">
                  <html><head></head><body>
                    <span id="some_text_in_an_iframe">Some text in an iframe</span>
                  </body></html>
                </iframe>
              </span>
            </body>
          </html>
        HTML
      end
    end
  end
end
