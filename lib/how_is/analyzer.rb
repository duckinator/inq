# frozen_string_literal: true

require "contracts"
require "date"
require "json"

class HowIs
  require "how_is/analysis"

  # Creates Analysis objects with input data formatted in useful ways.
  class Analyzer
    include Contracts::Core

    ##
    # Raised when attempting to import to an unsupported format.
    class UnsupportedImportFormat < StandardError
      def initialize(format)
        super("Unsupported import format: #{format}")
      end
    end

    ##
    # Generates and returns an analysis.
    #
    # @param data [Fetcher::Results] The results gathered by Fetcher.
    # @param analysis_class (You don't need this.) A class to use instead of
    #   HowIs::Analysis.
    Contract Fetcher::Results, C::KeywordArgs[analysis_class: C::Optional[Class]] => Analysis
    def call(data, analysis_class: Analysis)
      issues = data.issues
      pulls = data.pulls

      analysis_class.new(
        issues_url: "https://github.com/#{data.repository}/issues",
        pulls_url: "https://github.com/#{data.repository}/pulls",

        repository: data.repository,

        number_of_issues:  issues.length,
        number_of_pulls:   pulls.length,

        issues_with_label: with_label_links(num_with_label(issues), data.repository),
        issues_with_no_label: {"link" => nil, "total" => num_with_no_label(issues)},

        average_issue_age: average_age_for(issues),
        average_pull_age:  average_age_for(pulls),

        oldest_issue: issue_or_pull_to_hash(oldest_for(issues)),
        oldest_pull: issue_or_pull_to_hash(oldest_for(pulls)),

        newest_issue: issue_or_pull_to_hash(newest_for(issues)),
        newest_pull: issue_or_pull_to_hash(newest_for(pulls)),

        pulse: data.pulse
      )
    end

    ##
    # Generates an analysis from a hash of report data.
    #
    # @param data [Hash] The hash to generate an Analysis from.
    def self.from_hash(data)
      hash = data.map { |k, v|
        v = DateTime.parse(v) if k.end_with?("_date")

        [k, v]
      }.to_h

      hash.keys.each do |key|
        next unless hash[key].is_a?(Hash) && hash[key]["date"]

        hash[key]["date"] = DateTime.parse(hash[key]["date"])
      end

      Analysis.new(hash)
    end

    # Given an Array of issues or pulls, return a Hash specifying how many
    # issues or pulls use each label.
    def num_with_label(issues_or_pulls)
      # Returned hash maps labels to frequency.
      # E.g., given 10 issues/pulls with label "label1" and 5 with label "label2",
      # {
      #   "label1" => 10,
      #   "label2" => 5
      # }

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
      timestamps = issues_or_pulls.map { |iop| Date.parse(iop["created_at"]).strftime("%s").to_i }
      average_timestamp = timestamps.reduce(:+) / issues_or_pulls.length

      DateTime.strptime(average_timestamp.to_s, "%s")
    end

    # Given an Array of issues or pulls, return the average age of them.
    # Returns nil if no issues or pulls are provided.
    def average_age_for(issues_or_pulls)
      return nil if issues_or_pulls.empty?

      ages = issues_or_pulls.map { |iop| time_ago_in_seconds(iop["created_at"]) }
      average_age_in_seconds = ages.reduce(:+) / ages.length

      values = period_pairs_for(average_age_in_seconds).reject { |(v, _)| v.zero? }.map { |(v, k)|
        k += "s" if v != 1
        [v, k]
      }

      most_significant = values[0, 2].map { |x| x.join(" ") }

      value =
        if most_significant.length < 2
          most_significant.first
        else
          most_significant.join(" and ")
        end

      "approximately #{value}"
    end

    def sort_iops_by_created_at(issues_or_pulls)
      issues_or_pulls.sort_by { |x| DateTime.parse(x["created_at"]) }
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
      DateTime.parse(issue_or_pull["created_at"])
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

    def issue_or_pull_to_hash(iop)
      return nil if iop.nil?

      ret = {}

      ret["html_url"] = iop["html_url"]
      ret["number"] = iop["number"]
      ret["date"] = date_for(iop)

      ret
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
  end
end
