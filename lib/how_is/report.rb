# frozen_string_literal: true

require "how_is/frontmatter"
require "how_is/sources/github/contributions"
require "how_is/sources/github/issues"
require "how_is/sources/github/pulls"
require "how_is/sources/ci/travis"
require "how_is/sources/ci/appveyor"
require "json"

module HowIs
  ##
  # Class for generating a HowIs report.
  class Report
    def initialize(repository, end_date)
      # NOTE: Use DateTime because it defaults to UTC and that's less gross
      #       than trying to get Date to use UTC.
      #
      #       Not using UTC for this results in #compare_url giving different
      #       results for different time zones, which makes it harder to test.
      #
      #       (I'm also guessing/hoping that GitHub's URLs use UTC.)
      end_dt = DateTime.strptime(end_date, "%Y-%m-%d")
      start_dt = start_dt_from_end_dt(end_dt)

      @repository = repository
      @end_date = end_dt.strftime("%Y-%m-%d")
      @start_date = start_dt.strftime("%Y-%m-%d")
    end

    def contributions
      @gh_contributions ||= HowIs::Sources::Github::Contributions.new(@repository, @start_date, @end_date)
    end

    def issues
      @gh_issues ||= HowIs::Sources::Github::Issues.new(@repository, @start_date, @end_date)
    end

    def pulls
      @gh_pulls ||= HowIs::Sources::Github::Pulls.new(@repository, @start_date, @end_date)
    end

    def travis
      @travis ||= HowIs::Sources::CI::Travis.new(@repository, @start_date, @end_date)
    end

    def appveyor
      @appveyor ||= HowIs::Sources::CI::Appveyor.new(@repository, @start_date, @end_date)
    end

    def to_h(frontmatter_data = nil)
      @report_hash ||= report_hash
      frontmatter = HowIs::Frontmatter.generate(frontmatter_data, @report_hash)

      @report_hash.merge(frontmatter: frontmatter)
    end

    def to_html_partial(frontmatter = nil)
      template_data = to_h(frontmatter)

      Kernel.format(HowIs.template("report_partial.html_template"), template_data)
    end

    def to_html(frontmatter = nil)
      template_data = to_h(frontmatter).merge({report: to_html_partial})

      Kernel.format(HowIs.template("report.html_template"), template_data)
    end

    def to_json(frontmatter = nil)
      frontmatter.to_s + JSON.pretty_generate(to_h)
    end

    def save_as(filename)
      File.write(filename, to_format_for(filename))
    end

    def to_format_for(filename)
      format = File.extname(filename)[1..-1]
      send("to_#{format}")
    end
    private :to_format_for

    def start_dt_from_end_dt(end_dt)
      d = end_dt.day
      m = end_dt.month
      y = end_dt.year
      start_year = y
      start_month = m - 1
      if start_month <= 0
        start_month = 12 - start_month
        start_year -= 1
      end

      DateTime.new(start_year, start_month, d)
    end

    def report_hash
      {
        title: "How is #{@repository}?",
        repository: @repository,

        contributions_summary: contributions.to_html,
        issues_summary: issues.to_html,
        pulls_summary: pulls.to_html,
        issues_per_label: issues.issues_per_label_html,

        issues: issues.to_a,
        pulls: issues.to_a,

        average_issue_age: issues.average_age,
        average_pull_age:  pulls.average_age,

        oldest_issue_link: issues.oldest["url"],
        oldest_issue_date: issues.oldest["createdAt"],

        newest_issue_link: issues.newest["url"],
        newest_issue_date: issues.newest["createdAt"],

        newest_pull_link: pulls.newest["url"],
        newest_pull_date: pulls.newest["createdAt"],

        oldest_pull_link: pulls.oldest["url"],
        oldest_pull_date: pulls.oldest["createdAt"],

        travis_builds: travis.builds,
        appveyor_builds: appveyor.builds,

        date: @end_date,
      }
    end
  end
end
