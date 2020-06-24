# frozen_string_literal: true

module SitePrism
  class RspecMatchers
    def self.create_rspec_existence_matchers(element_name)
      new(element_name).create_rspec_existence_matchers
    end

    def initialize(element_name)
      @element_name = element_name
    end

    def create_rspec_existence_matchers
      matcher = "have_#{element_name}"
      object_method = "has_#{element_name}?"
      negated_object_method = "has_no_#{element_name}?"
      useless_method_to_save_lines(
        matcher,
        object_method,
        negated_object_method,
        method(:log_warning)
      )
    end

    private

    def useless_method_to_save_lines(matcher, object_method, negated_object_method, log_warning)
      RSpec::Matchers.define matcher do |*args|
        match { |actual| actual.public_send(object_method, *args) }
        match_when_negated do |actual|
          if actual.respond_to?(negated_object_method)
            return actual.public_send(negated_object_method, *args)
          end

          log_warning.call(matcher, negated_object_method)
          !actual.public_send(object_method, *args)
        end
      end
    end

    attr_reader :element_name

    def log_warning(matcher, negated_object_method)
      warning = [
        "#{matcher} was handled by a matcher added by site prism, but the object under",
        "test does not respond to #{negated_object_method} and is probably not a site",
        'prism page. Attempting to mimic the rspec standard matcher that site prism',
        'replaced.',
      ].join(' ')
      SitePrism.logger.debug(warning)
    end
  end
end
