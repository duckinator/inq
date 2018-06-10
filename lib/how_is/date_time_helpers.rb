# frozen_string_literal: true

require "how_is/version"
require "how_is/sources/github"
require "how_is/sources/github_helpers"
require "date"

module HowIs
  module DateTimeHelpers
    def date_le(left, right)
      left  = str_to_dt(left)
      right = str_to_dt(right)

      left <= right
    end

    def date_ge(left, right)
      left  = str_to_dt(left)
      right = str_to_dt(right)

      left >= right
    end

    private

    def str_to_dt(str)
      DateTime.parse(str)
    end
  end
end
