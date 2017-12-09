# frozen_string_literal: true

require "how_is/sources/github/contributions"
require "how_is/sources/travis"

module HowIs
  class Report
    def initialize(repository, end_date)
      @repository = repository
      @end_date = end_date

      @gh_contributions = HowIs::Sources::Github::Contributions.new(repository, end_date)
      #@gh_issues        = HowIs::Sources::Github::Issues.new(repository, end_date)
      #@gh_pulls         = HowIs::Sources::Github::Pulls.new(repository, end_date)
      @travis           = HowIs::Sources::Travis.new(repository, end_date)
    end

    def to_h
      @report_hash ||= {
        title: "How is #{@repository}?",
        repository: @repository,
        contributions: @gh_contributions.to_s,
        issues_summary: "TODO",
        pulls_summary: "TODO",
        #issues_summary: @gh_issues.to_s,
        #pulls_summary: @gh_pulls.to_s,
        #issues: @gh_issues.to_h,
        #pulls: @gh_issues.to_h,
        average_issue_age: "TODO",
        oldest_issue_link: "TODO",
        oldest_issue_date: "TODO",
        newest_issue_link: "TODO",
        newest_issue_date: "TODO",
        travis_builds: @travis.builds.to_h,
      }
    end

    def to_html_partial
      Kernel.format(template('report_partial.html_template'), to_h)
    end

    def to_html
      Kernel.format(template('report.html_template'), to_h.merge({report: to_html_partial}))
    end

    def to_json
      to_h.to_json
    end

    private

    def template(filename)
      dir  = File.expand_path("./templates/", __dir__)
      path = File.join(dir, filename)

      open(path).read
    end
  end
end
