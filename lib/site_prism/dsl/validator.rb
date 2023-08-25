# frozen_string_literal: true

module SitePrism
  module DSL
    # [SitePrism::DSL::Validators]
    #
    # This is the new validator module which will check all DSL items against a whitelist
    # for any entries which break specific rules
    #
    # @api private
    #
    module Validator
      attr_accessor :dsl_name_error

      def name_invalid?(name)
        prefix_invalid?(name) ||
          suffix_invalid?(name) ||
          characters_invalid?(name) ||
          blacklisted?(name)
      end

      private

      def prefix_invalid?(name)
        return unless prefix_blacklist.any? { |prefix| name.start_with?(prefix) }

        log_failure(name, 'prefix')
      end

      def suffix_invalid?(name)
        return unless suffix_blacklist.any? { |prefix| name.end_with?(prefix) }

        log_failure(name, 'suffix')
      end

      def characters_invalid?(name)
        return if name.match?(regex_permission)

        log_failure(name, 'character(s)')
      end

      def blacklisted?(name)
        return unless blacklisted_names.include?(name)

        log_failure(name, 'name (blacklisted entry)')
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
          element
          elements
          section
          sections
          iframe
        ]
      end

      def log_failure(name, type)
        self.dsl_name_error = "DSL item: #{name} has an invalid #{type}"
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
