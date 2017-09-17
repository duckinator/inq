# frozen_string_literal: true

require "contracts"
require "ostruct"
require "date"
require "json"
require "how_is/analysis_helpers"

class HowIs
  # Creates Analysis objects with input data formatted in useful ways.
  class Analysis < OpenStruct
    include Contracts::Core

    # TODO: What the actual fuck am I even doing?
    include AnalysisHelpers
    extend AnalysisHelpers

    # initialize() is inherited from OpenStruct.

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
    Contract Fetcher::Results => Analysis
    def self.from_fetcher_results(data)
      issues = data.issues
      pulls = data.pulls

      new(
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

  end
end
