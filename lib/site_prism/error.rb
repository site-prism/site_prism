# frozen_string_literal: true

module SitePrism
  module Error
    # Generic SitePrism family of errors which specific errors are children of
    class SitePrismError < StandardError; end

    # A page calls #load with no URL set
    class NoUrlForPageError < SitePrismError; end

    # A page calls #displayed? with no URL matcher set
    class NoUrlMatcherForPageError < SitePrismError; end

    # The URL matcher was not recognised as a Regex or String and as such
    # it couldn't be parsed by Addressable. It also could be caused by
    # the usage of templated port numbers - which aren't supported
    class InvalidUrlMatcherError < SitePrismError; end

    # A SitePrism defined DSL item was defined without a selector
    class InvalidElementError < SitePrismError; end

    # The condition that was being evaluated inside the block did not evaluate
    # to true within the time limit
    class TimeoutError < SitePrismError; end

    # The wait_until_*_visible meta-programmed method didn't evaluate to true
    # within the prescribed time limit
    class ElementVisibilityTimeoutError < TimeoutError; end

    # The wait_until_*_invisible meta-programmed method didn't evaluate to true
    # within the prescribed time limit
    class ElementInvisibilityTimeoutError < TimeoutError; end

    # A Block was passed to the method, which it cannot interpret
    class UnsupportedBlockError < SitePrismError; end

    # A Block was required, but not supplied
    class MissingBlockError < SitePrismError; end

    # A page was loaded then failed one of the validations defined by the user
    class FailedLoadValidationError < SitePrismError; end

    # DSL items are not permitted to be named in certain ways
    class InvalidDSLNameError < SitePrismError; end

    # The version of the target gem is unsupported, so using that feature is not possible
    class UnsupportedGemVersionError < SitePrismError; end
  end
end
