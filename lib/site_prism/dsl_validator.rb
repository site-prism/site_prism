# frozen_string_literal: true

module SitePrism
  # [SitePrism::DSLValidator]
  #
  # This is the new validator module which will check all DSL items against a whitelist
  # for any entries which are prohibited
  module DSLValidator
    def invalid?(name)
      prefix_invalid?(name) || suffix_invalid?(name) || characters_invalid?(name)
    end

    private

    def prefix_invalid?(name)
      prefix_blacklist.any? { |prefix| name.start_with?(prefix) }.tap { |result| log_failure(name, 'prefix') unless result }
    end

    def suffix_invalid?(name)
      suffix_blacklist.any? { |prefix| name.end_with?(prefix) }.tap { |result| log_failure(name, 'suffix') unless result }
    end

    def characters_invalid?(name)
      !name.match?(regex_permission).tap { |result| log_failure(name, 'character-set') unless result }
    end

    def regex_permission
      /^[a-z]\w+$/
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
        ?
      ]
    end

    def log_failure(name, type)
      SitePrism.logger.error("DSL item: #{name} has an invalid #{type}")
    end
  end
end
