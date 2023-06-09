# frozen_string_literal: true

# Placeholder reference whilst we try stitch up items
require 'site_prism/dsl/builder'
require 'site_prism/dsl/d_s_l'
require 'site_prism/dsl/locators'
require 'site_prism/dsl/validators'

module SitePrism
  # [SitePrism::DSL]
  #
  # This is the core Module Namespace for all of the public-facing DSL methods
  #   such as `element`. The code here is designed to be used through the defining
  #   of said items, and not to be instantiated directly.
  #
  # The whole package here can be thought of as [@api private]
  #
  module DSL
    def self.included(klass)
      klass.extend Builder
      klass.extend D_S_L
      klass.include Locators
      klass.extend Validators
    end

    private

    def raise_if_runtime_block_supplied(object, name, has_block, type)
      return unless has_block

      SitePrism.logger.debug("Type passed in: #{type}")
      SitePrism.logger.error("#{object.class}##{name} cannot accept runtime blocks")
      raise SitePrism::UnsupportedBlockError
    end
  end
end
