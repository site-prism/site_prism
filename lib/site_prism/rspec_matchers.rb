# frozen_string_literal: true

module SitePrism
  #
  # @api private
  #
  class RSpecMatchers
    attr_reader :element_name

    def initialize(element_name)
      @element_name = element_name
    end

    # Create the positive and negative rspec matchers that will use the SitePrism boolean methods
    #
    # @return [Symbol]
    def _create_rspec_existence_matchers
      SitePrism.logger.debug('Including all relevant matcher names / warnings in RSpec scope.')
      create_rspec_existence_matchers(matcher, object_method, negated_object_method, warning)
    end

    private

    def create_rspec_existence_matchers(matcher, object_method, negated_object_method, warning)
      forward = forwarder(object_method)

      RSpec::Matchers.define(matcher) do |*args, **options|
        match { |actual| forward.call(actual, args, options) }
        match_when_negated do |actual|
          return forward.call(actual, args, options, negated_object_method) if actual.respond_to?(negated_object_method)

          SitePrism.logger.debug(warning)
          !forward.call(actual, args, options)
        end
      end
    end

    def forwarder(object_method)
      lambda do |actual, args, options, method_name = object_method|
        # To support Ruby 2.6. Otherwise methods that expect no arguments would fail with
        # "wrong number of arguments (given 1, expected 0)" because Ruby 2.6 considers `method(**{})` the
        # same as `method({})` (passing the empty Hash as an argument)
        next actual.public_send(method_name, *args) if options.empty?

        actual.public_send(method_name, *args, **options)
      end
    end

    def matcher
      "have_#{element_name}"
    end

    def object_method
      "has_#{element_name}?"
    end

    def negated_object_method
      "has_no_#{element_name}?"
    end

    def warning
      "The RSpec matcher '#{matcher}' was added by SitePrism, but the object under test " \
        "does not respond to '#{negated_object_method}' and is probably not a SitePrism object. " \
        'Falling back to the default RSpec matcher.'
    end
  end
end
