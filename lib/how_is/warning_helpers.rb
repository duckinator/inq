# frozen_string_literal: true

module HowIs
  ##
  # Helper functions for suppressing warnings when we know it's okay.
  module WarningHelpers
    def silence_warnings(&block)
      with_warnings(nil, &block)
    end

    def with_warnings(flag, &_block)
      old_verbose = $VERBOSE
      $VERBOSE = flag
      yield
    ensure
      $VERBOSE = old_verbose
    end
  end
end
