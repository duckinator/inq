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

      # Given an Array of issues or pulls, return a Hash specifying how many
      # issues or pulls use each label.
      #
      # Returned hash maps labels to frequency.
      # E.g., given 10 issues/pulls with label "label1" and 5 with label "label2",
      # {
      #   "label1" => 10,
      #   "label2" => 5
      # }
      def num_with_label(issues_or_pulls)
        hash = Hash.new(0)
        issues_or_pulls.each do |iop|
          next unless iop["labels"]

          iop["labels"].each do |label|
            hash[label["name"]] += 1
          end
        end
        hash
      end

      # Returns the number of issues with no label.
      def num_with_no_label(issues)
        issues.select { |x| x["labels"].empty? }.length
      end

      # Given an Array of dates, average the timestamps and return the date that
      # represents.
      def average_date_for(issues_or_pulls)
        timestamps = issues_or_pulls.map { |iop| DateTime.parse(iop["createdAt"]).strftime("%s").to_i }
        average_timestamp = timestamps.reduce(:+) / issues_or_pulls.length

        DateTime.strptime(average_timestamp.to_s, "%s")
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

      # Given an issue or PR, returns the date it was created.
      def date_for(issue_or_pull)
        DateTime.parse(issue_or_pull["createdAt"])
      end

      def label_url_for(label_name)
        if label_name == "(No label)"
          url({"no"=>"label"})
        else
          url({"label"=>label_name})
        end
      end

      private

      # Takes an Array of labels, and returns amodified list that includes links
      # to each label.
      def with_label_links(labels, repository)
        labels.map { |label, num_issues|
          label_link = "https://github.com/#{repository}/issues?q=" + CGI.escape("is:open is:issue label:\"#{label}\"")

          [label, {"link" => label_link, "total" => num_issues}]
        }.to_h
      end

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

      def are_or_is(number)
        if number == 1
          "is"
        else
          "are"
        end
      end

      def pretty_date(date_or_str)
        if date_or_str.is_a?(DateTime)
          date = datetime_or_str
        elsif date_or_str.is_a?(String)
          date = DateTime.parse(date_or_str)
        else
          raise ArgumentError, "expected DateTime or String, got #{date_or_str.class}"
        end

        date.strftime("%b %_d, %Y")
      end
    end
  end
end
