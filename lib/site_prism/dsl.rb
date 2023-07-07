# frozen_string_literal: true

require 'site_prism/dsl/builder'
require 'site_prism/dsl/methods'
require 'site_prism/dsl/locators'
require 'site_prism/dsl/validators'

module SitePrism
  # [SitePrism::DSL]
  #
  # This is the core internal Module for SitePrism. Internally it consists of four moving parts - plus some generic methods in this module
  #   Builder -> The way in which the .build method generates lots of instance-methods on a Class/Section instance
  #   Methods -> The public DSL metaprogram methods, such as `element` or `section`
  #   Locators -> We are scoped to capybara, and as such our locators need to be scoped using `#to_capybara_node`
  #   Validators -> EXPERIMENTAL: A new module used to ensure names of all DSL items conform to certain rules
  #
  module DSL
    def self.included(klass)
      klass.extend Builder
      klass.extend Methods
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
