# frozen_string_literal: true

require "how_is/sources/github"
require "date"

module HowIs
  module Sources
    ##
    # Helper functions used by GitHub-related sources.
    module GithubHelpers
      def obj_to_array_of_hashes(object)
        object.to_a.map(&:to_h)
      end

      # Given an Array of issues or pulls, return the average age of them.
      # Returns nil if no issues or pulls are provided.
      def average_age_for(issues_or_pulls)
        return nil if issues_or_pulls.empty?

        ages = issues_or_pulls.map { |iop| time_ago_in_seconds(iop["createdAt"]) }
        average_age_in_seconds = ages.reduce(:+) / ages.length

        values =
          period_pairs_for(average_age_in_seconds) \
            .reject { |(v, _)| v.zero? } \
            .map { |(v, k)| pluralize(k, v) }

        value = values[0, 2].join(" and ")

        "approximately #{value}"
      end

      def sort_iops_by_created_at(issues_or_pulls)
        issues_or_pulls.sort_by { |x| DateTime.parse(x["createdAt"]) }
      end

      # Given an Array of issues or pulls, return the oldest.
      # Returns nil if no issues or pulls are provided.
      def oldest_for(issues_or_pulls)
        return nil if issues_or_pulls.empty?

        sort_iops_by_created_at(issues_or_pulls).first
      end

      # Given an Array of issues or pulls, return the newest.
      # Returns nil if no issues or pulls are provided.
      def newest_for(issues_or_pulls)
        return nil if issues_or_pulls.empty?

        sort_iops_by_created_at(issues_or_pulls).last
      end

      private

      # Returns how many seconds ago a date (as a String) was.
      def time_ago_in_seconds(x)
        DateTime.now.strftime("%s").to_i - DateTime.parse(x).strftime("%s").to_i
      end

      SECONDS_IN_A_YEAR = 31_556_926
      SECONDS_IN_A_MONTH = 2_629_743
      SECONDS_IN_A_WEEK = 604_800
      SECONDS_IN_A_DAY = 86_400

      # Calculates a list of pairs of value and period label.
      #
      # @param age_in_seconds [Float]
      #
      # @return [Array<Array>] The input age_in_seconds expressed as different
      #                        units, as pairs of value and unit name.
      def period_pairs_for(age_in_seconds)
        years_remainder = age_in_seconds % SECONDS_IN_A_YEAR

        months_remainder = years_remainder % SECONDS_IN_A_MONTH

        weeks_remainder = months_remainder % SECONDS_IN_A_WEEK

        [
          [age_in_seconds / SECONDS_IN_A_YEAR, "year"],
          [years_remainder / SECONDS_IN_A_MONTH, "month"],
          [months_remainder / SECONDS_IN_A_WEEK, "week"],
          [weeks_remainder / SECONDS_IN_A_DAY, "day"],
        ]
      end

      def pluralize(string, number, zero_is_no: false)
        number_str = number
        number_str = "no" if number.zero? && zero_is_no

        "#{number_str} #{string}#{(number == 1) ? '' : 's'}"
      end

      def pretty_date(date_or_str)
        if date_or_str.is_a?(DateTime)
          date = datetime_or_str
        elsif date_or_str.is_a?(String)
          date = DateTime.parse(date_or_str)
        else
          raise ArgumentError, "expected DateTime or String, got #{date_or_str.class}"
        end

        date.strftime("%b %d, %Y")
      end
    end
  end
end
