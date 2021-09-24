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
        generic_blacklist.any? { |prefix| name.include?(prefix) }
    end

    private

    def generic_blacklist
      [
        " "
      ]
    end

    def prefix_blacklist
      [
        "no_",
        "_"
      ]
    end

    def suffix_blacklist
      [
        "_"
      ]
    end
  end
end
