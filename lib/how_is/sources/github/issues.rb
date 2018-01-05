# frozen_string_literal: true

require "how_is/version"
require "how_is/sources/github"
require "how_is/sources/github_helpers"
require "date"

module HowIs::Sources
  class Github
    class Issues
      include HowIs::Sources::GithubHelpers

      def initialize(repository, end_date)
        @repository = repository
        @user, @repo = repository.split("/", 2)
      end

      def url
        "https://github.com/#{@repository}/#{type}"
      end

      def average_age
        average_age_for(@data)
      end

      def oldest
        fetch!
        oldest_for(@data) || {}
      end

      def newest
        fetch!
        newest_for(@data) || {}
      end

      def summary
        number_open = to_a.length
        pretty_number =
          pluralize(pretty_type, number_open, zero_is_no: true)

        "There #{are_or_is(number_open)} <a href=\"#{url}\">#{pretty_number} open</a>."
      end

      def to_html
        fetch!

        summary_ = "<p>#{summary}</p>"

        return summary_ if to_a.empty?

        template_data = {
          summary: summary_,
          average_age: average_age,
          type: type,
          pretty_type: pretty_type,

          oldest_link: oldest[:link],
          oldest_date: pretty_date(oldest[:created_at]),

          newest_link: newest[:link],
          newest_date: pretty_date(newest[:created_at]),
        }

        Kernel.format(HowIs.template("issues_or_pulls_partial.html_template"), template_data)
      end

      # TODO: Clean up Issues Per Label stuff, or replace it with different functionality.

      def issues_per_label
        ipl = with_label_links(num_with_label(@data), @repository)
        number_with_no_label = num_with_no_label(@data)

        if number_with_no_label > 0
          ipl["(No label)"] = {
            "link"  => nil,
            "total" => number_with_no_label,
          }
        end

        ipl
      end

      HTML_GRAPH_ROW = <<-EOF
  <tr>
    <td style="width: %{label_width}">%{label_text}</td>
    <td><span class="fill" style="width: %{percentage}%%">%{link_text}</span></td>
  </tr>
      EOF

      def issues_per_label_html
        data = issues_per_label

        return "<p>There are no open issues to graph.</p>" if data.empty?

        biggest = data.map { |_label, info| info["total"] }.max
        get_percentage = ->(number_of_issues) { number_of_issues * 100 / biggest }

        longest_label_length = data.map(&:first).map(&:length).max
        label_width = "#{longest_label_length}ch"

        parts = data.map { |label, info|
          # TODO: Remove this hack to get around unlabeled issues not having a link.
          label_text = label
          unless info["link"].nil?
            label_text = '<a href="' + info["link"] + '">' + label_text + '</a>'
          end

          Kernel.format(HTML_GRAPH_ROW, {
            label_width: label_width,
            label_text: label_text,
            label_link: info["link"],
            percentage: get_percentage.call(info["total"]),
            link_text: info["total"].to_s,
          })
        }

        "<table class=\"horizontal-bar-graph\">\n" +
        parts.join("\n") +
        "\n</table>"
      end

      def to_a
        fetch!
        obj_to_array_of_hashes(@data)
      end

      private

      def type
        "issues"
      end

      def pretty_type
        "issue"
      end

      def fetch!
        @data ||= Github.rest.send(type).list(user: @user, repo: @repo)
      end

      def fetch_graphql!
        # mmmm, scoping weirdness.
        type_ = type
        user_ = @user
        repo_ = @repo
        query = Okay::GraphQL.query {
          repository(owner: user_, name: repo_) {
            send(type_, first: 10) {
              edges {
                node {
                  number
                  createdAt
                  closedAt
                  updatedAt
                  state
                  title
                  url
                }
              }
            }
          }
        }

        headers = { bearer_token: HowIs::Sources::Github::ACCESS_TOKEN }
        query.submit!(:github, headers).or_raise!.from_json
      end
    end
  end
end
