# frozen_string_literal: true

module SitePrism
  # [SitePrism::DSLValidator]
  #
  # This is the new validator module which will check all DSL items against a whitelist
  # for any entries which are prohibited
  module DSLValidator
    def invalid?(name)
      prefix_blacklist.any? { |prefix| name.start_with?(prefix) } ||
        suffix_blacklist.any? { |prefix| name.end_with?(prefix) } ||
        !name.match?(regex_permission)
    end

    private

    def regex_permission
      /^\w+$/
    end

    def prefix_blacklist
      %w[
        no_
        _
      ]
    end

    def suffix_blacklist
      %w[
        _
      ]
    end
  end
end
