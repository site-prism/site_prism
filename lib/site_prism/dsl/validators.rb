# frozen_string_literal: true

module SitePrism
  module DSL
    # [SitePrism::DSL::Validator]
    #
    # This is a newly migrated experimental way of partitioning the SitePrism internal DSL
    #
    # It is currently completely switched off and disabled / untested, and will remain this way for all of v4
    #
    # ~~~~~~~~~~~~~ PREVIOUS DOCUMENTATION ~~~~~~~~~~~~~
    #
    # [SitePrism::DSLValidator]
    #
    # This is the new validator module which will check all DSL items against a whitelist
    # for any entries which are prohibited
    module Validators
      def self.included
        SitePrism.logger.error('The new experimental DSL partitioning has been required. Code will now crash!')
        raise SitePrismError
      end
      
      def invalid?(name)
        prefix_invalid?(name) ||
          suffix_invalid?(name) ||
          characters_invalid?(name) ||
          blacklisted?(name)
      end

      private

      def prefix_invalid?(name)
        prefix_blacklist.any? { |prefix| name.start_with?(prefix) }.tap { |result| log_failure(name, 'prefix') unless result }
      end

      def suffix_invalid?(name)
        suffix_blacklist.any? { |prefix| name.end_with?(prefix) }.tap { |result| log_failure(name, 'suffix') unless result }
      end

      def characters_invalid?(name)
        !name.match?(regex_permission).tap { |result| log_failure(name, 'character(s)') unless result }
      end

      def blacklisted?(name)
        blacklisted_names.include?(name).tap { |result| log_failure(name, 'name (blacklisted entry)') unless result }
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

      def blacklisted_names
        %w[
          attributes
          html
          no
          title
        ]
      end

      def log_failure(name, type)
        SitePrism.logger.error("DSL item: #{name} has an invalid #{type}")
        SitePrism.logger.debug(debug_error(type))
      end

      def debug_error(type)
        case type
        when 'prefix';       then "Invalid Prefixes: #{prefix_blacklist.join(', ')}."
        when 'suffix';       then "Invalid Suffixes: #{suffix_blacklist.join(', ')}"
        when 'character(s)'; then "Invalid DSL Names: #{blacklisted_names.join(', ')}"
        else                      "DSL Charset REGEX: #{regex_permission.inspect}"
        end
      end
    end
  end
end
