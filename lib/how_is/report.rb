# frozen_string_literal: true

require "how_is/frontmatter"
require "how_is/sources/github/contributions"
require "how_is/sources/github/issues"
require "how_is/sources/github/pulls"
require "how_is/sources/travis"

module HowIs
  class Report
    def initialize(repository, end_date)
      @repository = repository

      # NOTE: Use DateTime because it defaults to UTC and that's less gross
      #       than trying to get Date to use UTC.
      #
      #       Not using UTC for this results in #compare_url giving different
      #       results for different time zones, which makes it harder to test.
      #
      #       (I'm also guessing/hoping that GitHub's URLs use UTC.)
      end_dt = DateTime.strptime(end_date, "%Y-%m-%d")

      d = end_dt.day
      m = end_dt.month
      y = end_dt.year
      start_year = y
      start_month = m - 1
      if start_month <= 0
        start_month = 12 - start_month
        start_year -= 1
      end
      start_dt = DateTime.new(start_year, start_month, d)

      @end_date = end_dt.strftime("%Y-%m-%d")
      @start_date = start_dt.strftime("%Y-%m-%d")

      @gh_contributions = HowIs::Sources::Github::Contributions.new(repository, @start_date, @end_date)
      @gh_issues        = HowIs::Sources::Github::Issues.new(repository, @start_date, @end_date)
      @gh_pulls         = HowIs::Sources::Github::Pulls.new(repository, @start_date, @end_date)
      @travis           = HowIs::Sources::Travis.new(repository, @start_date, @end_date)
    end

    def to_h(frontmatter_data = nil)
      @report_hash ||= {
        title: "How is #{@repository}?",
        repository: @repository,

        contributions_summary: @gh_contributions.to_html,
        issues_summary: @gh_issues.to_html,
        pulls_summary: @gh_pulls.to_html,
        issues_per_label: @gh_issues.issues_per_label_html,

        issues: @gh_issues.to_a,
        pulls: @gh_issues.to_a,

        average_issue_age: @gh_issues.average_age,
        average_pull_age:  @gh_pulls.average_age,

        oldest_issue_link: @gh_issues.oldest["url"],
        oldest_issue_date: @gh_issues.oldest["createdAt"],

        newest_issue_link: @gh_issues.newest["url"],
        newest_issue_date: @gh_issues.newest["createdAt"],

        newest_pull_link: @gh_pulls.newest["url"],
        newest_pull_date: @gh_pulls.newest["createdAt"],

        oldest_pull_link: @gh_pulls.oldest["url"],
        oldest_pull_date: @gh_pulls.oldest["createdAt"],

        travis_builds: @travis.builds.to_h,

        date: @end_date,
      }

      frontmatter =
        if frontmatter_data
          HowIs::Frontmatter.generate(frontmatter_data, @report_hash)
        else
          ""
        end

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
  end
end
