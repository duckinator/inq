# frozen_string_literal: true

require "how_is/version"
require "date"

module HowIs
  ##
  # Various helper functions for working with DateTime objects.
  module DateTimeHelpers
    # Check if +left+ is less than or equal to +right+, where both are string
    # representations of a date.
    #
    # @param left [String] A string representation of a date.
    # @param right [String] A string representation of a date.
    # @return [Boolean] True if +left+ is less-than-or-equal to +right+,
    #   otherwise false.
    def date_le(left, right)
      left  = str_to_dt(left)
      right = str_to_dt(right)

      left <= right
    end

    # Check if +left+ is greater than or equal to +right+, where both are string
    # representations of a date.
    #
    # @param left [String] A string representation of a date.
    # @param right [String] A string representation of a date.
    # @return [Boolean] True if +left+ is greater-than-or-equal to +right+,
    #   otherwise false.
    def date_ge(left, right)
      left  = str_to_dt(left)
      right = str_to_dt(right)

      left >= right
    end

    private

    # Converts a +String+ representation of a date to a +DateTime+.
    #
    # @param str [String] A date.
    # @return [DateTime] A DateTime representation of +str+.
    def str_to_dt(str)
      DateTime.parse(str)
    end
  end
end
