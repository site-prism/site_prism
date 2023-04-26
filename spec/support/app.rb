module SitePrism
  module Support
    class MyTestApp
      def call(_env)
        [200, { 'Content-Length' => '9' }, ['MyTestApp']]
      end
    end
  end
end
