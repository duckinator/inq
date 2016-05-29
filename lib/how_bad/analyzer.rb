require 'contracts'
require 'ostruct'

module HowBad
  ##
  # Represents a completed analysis of the repository being analyzed.
  class Analysis < OpenStruct
  end

  class Analyzer
    include Contracts::Core

    Contract Fetcher::Results, Class => Analysis
    def call(data, analysis_class: Analysis)

      analysis_class.new(
        total_issues:  data.issues.length,
        total_pulls:   data.pulls.length,

        average_issue_age: average_age_for(issues),
        oldest_issue_date: oldest_date_for(issues),

        average_pull_age:  average_age_for(pulls),
        oldest_pull_date:  oldest_date_for(pulls),
      )
    end

    def average_age_for(issues_or_pulls)
      0 # TODO: Implement.
    end

    def oldest_date_for(issues_or_pulls)
      0 # TODO: Implement.
    end
  end
end
