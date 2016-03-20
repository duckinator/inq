require "contracts"
require 'ostruct'

module HowBad
  class Analysis < OpenStruct
  end

  class Analyzer
    include Contracts::Core

    Contract C::KeywordArgs[issues: C::Not[nil], pulls: C::Not[nil]] => Analysis
    def call(issues:, pulls:)
       Analysis.new(
         total_issues:  issues.length,
         total_pulls:   pulls.length,

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
