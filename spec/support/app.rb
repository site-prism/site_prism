# frozen_string_literal: true

module SitePrism
  module Support
    class App
      def call(_env)
        [200, { 'Content-Length' => '9' }, ['MyTestApp']]
      end
    end
  end
end
