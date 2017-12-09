# frozen_string_literal: true

require "how_is/sources/github/contributions"
require "how_is/sources/github/issues"
require "how_is/sources/github/pulls"
require "how_is/sources/travis"

module HowIs
  class Report
    def initialize(repository, end_date)
      @repository = repository
      @end_date = end_date

      @gh_contributions = HowIs::Sources::Github::Contributions.new(repository, end_date)
      @gh_issues        = HowIs::Sources::Github::Issues.new(repository, end_date)
      @gh_pulls         = HowIs::Sources::Github::Pulls.new(repository, end_date)
      @travis           = HowIs::Sources::Travis.new(repository, end_date)
    end

    def to_h
      @report_hash ||= {
        title: "How is #{@repository}?",
        repository: @repository,

        contributions_summary: @gh_contributions.to_html,
        issues_summary: @gh_issues.to_html,
        pulls_summary: @gh_pulls.to_html,
        issues_per_label: @gh_issues.issues_per_label_html,

        issues: @gh_issues.to_a,
        pulls: @gh_issues.to_a,

        number_of_issues: @gh_issues.to_a.length,
        number_of_pulls:  @gh_pulls.to_a.length,

        average_issue_age: @gh_issues.average_age,
        average_pull_age:  @gh_pulls.average_age,

        oldest_issue_link: @gh_issues.oldest[:link],
        oldest_issue_date: @gh_issues.oldest[:creation_date],

        newest_issue_link: @gh_issues.newest[:link],
        newest_issue_date: @gh_issues.newest[:creation_date],

        oldest_pull_link: @gh_pulls.oldest[:link],
        oldest_pull_date: @gh_pulls.oldest[:creation_date],

        travis_builds: @travis.builds.to_h,
      }
    end

    def to_html_partial
      Kernel.format(HowIs.template('report_partial.html_template'), to_h)
    end

    def to_html
      Kernel.format(HowIs.template('report.html_template'), to_h.merge({report: to_html_partial}))
    end

    def to_json
      to_h.to_json
    end
  end
end
