# frozen_string_literal: true

module SitePrism
  class RspecMatchers
    def self.create_rspec_existence_matchers(element_name)
      new(element_name).create_rspec_existence_matchers
    end

    attr_reader :element_name

    def initialize(element_name)
      @element_name = element_name
    end

    def create_rspec_existence_matchers
      useless_method_to_save_lines(matcher, object_method, negated_object_method, warning)
    end

    # this method only exists so that all of the arguments are accessible when the matcher is
    # actualy invoked, otherwise we get a bunch of NameErrors because the methods on this class are
    # no longer available to the matcher. We could assign them to local variable in a single method,
    # but rubocop's method length limit says no, so we use method arguments sneak past that limit.
    def useless_method_to_save_lines(matcher, object_method, negated_object_method, warning)
      RSpec::Matchers.define(matcher) do |*args|
        match { |actual| actual.public_send(object_method, *args) }
        match_when_negated do |actual|
          if actual.respond_to?(negated_object_method)
            return actual.public_send(negated_object_method, *args)
          end

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
      [
        "#{matcher} was handled by a matcher added by site prism, but the object under",
        "test does not respond to #{negated_object_method} and is probably not a site",
        'prism page. Attempting to mimic the rspec standard matcher that site prism',
        'replaced.',
      ].join(' ')
    end
  end
end
