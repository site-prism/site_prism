# frozen_string_literal: true

module SitePrism
  class RspecMatchers
    attr_reader :element_name

    def initialize(element_name)
      @element_name = element_name
    end

    def _create_rspec_existence_matchers
      SitePrism.logger.debug('Including all relevant matcher names / warnings in RSpec scope.')
      create_rspec_existence_matchers(matcher, object_method, negated_object_method, warning)
    end

    private

    def create_rspec_existence_matchers(matcher, object_method, negated_object_method, warning)
      RSpec::Matchers.define(matcher) do |*args|
        match { |actual| actual.public_send(object_method, *args) }
        match_when_negated do |actual|
          return actual.public_send(negated_object_method, *args) if actual.respond_to?(negated_object_method)

          SitePrism.logger.debug(warning)
          !actual.public_send(object_method, *args)
        end
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
      "The RSpec matcher '#{matcher}' was added by SitePrism, but the object under test "\
        "does not respond to '#{negated_object_method}' and is probably not a SitePrism object. "\
        'Falling back to the default RSpec matcher.'
    end
  end
end
