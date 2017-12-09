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
      @report ||= {
        contributions: @gh_contributions.to_s,
        #issues: @gh_issues.to_h,
        #pulls: @gh_issues.to_h,
        travis_builds: @travis.builds.to_h,
      }
    end

    def to_html
      Kernel.format(template('report.html_template'), to_h)
    end

    def to_json
      to_h.to_json
    end
  end
end
