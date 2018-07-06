# frozen_string_literal: true

require "how_is/version"
require "how_is/date_time_helpers"
require "how_is/sources/github"
require "how_is/sources/github_helpers"
require "how_is/sources/github/issue_fetcher"
require "date"

module HowIs
  module Sources
    class Github
      ##
      # Fetches various information about GitHub Issues.
      class Issues
        include HowIs::DateTimeHelpers
        include HowIs::Sources::GithubHelpers

        def initialize(repository, start_date, end_date)
          @repository = repository
          @start_date = start_date
          @end_date = end_date
        end

        def url(values = {})
          defaults = {
            "is" => singular_type,
            "created" => "#{@start_date}..#{@end_date}",
          }
          values = defaults.merge(values)
          raw_query = values.map { |k, v|
            [k, v].join(":")
          }.join(" ")

          query = CGI.escape(raw_query)

          "https://github.com/#{@repository}/#{url_suffix}?q=#{query}"
        end

        def average_age
          average_age_for(data)
        end

        def oldest
          result = oldest_for(data)
          return {} if result.nil?

          result["date"] = pretty_date(result["createdAt"])

          result
        end

        def newest
          result = newest_for(data)
          return {} if result.nil?

          result["date"] = pretty_date(result["createdAt"])

          result
        end

        def summary
          number_open = to_a.length
          pretty_number = pluralize(pretty_type, number_open, zero_is_no: true)

          "<p>There #{are_or_is(number_open)} <a href=\"#{url}\">#{pretty_number} open</a>.</p>"
        end

        def to_html
          return summary if to_a.empty?

          HowIs.apply_template("issues_or_pulls_partial", {
            summary: summary,
            average_age: average_age,
            pretty_type: pretty_type,

            oldest_link: oldest["url"],
            oldest_date: oldest["date"],

            newest_link: newest["url"],
            newest_date: newest["date"],
          })
        end

        # TODO: Clean up Issues Per Label stuff, or replace it with different functionality.

        def issues_per_label
          ipl = with_label_links(num_with_label(data), @repository)
          number_with_no_label = num_with_no_label(data)

          if number_with_no_label > 0
            ipl["(No label)"] = {
              "name" => "(No label)",
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
          ipl = issues_per_label

          return "<p>There are no open issues to graph.</p>" if ipl.empty?

          biggest = ipl.map { |_label, info| info["total"] }.max

          longest_label_length = ipl.map(&:first).map(&:length).max
          label_width = "#{longest_label_length}ch"

          parts = ipl.map { |label, info|
            format_graph_row(label, info, label_width, biggest)
          }

          "<table class=\"horizontal-bar-graph\">\n" +
          parts.join("\n") +
          "\n</table>"
        end

        def to_a
          obj_to_array_of_hashes(data)
        end

        private

        def format_graph_row(label, info, label_width, biggest)
          label_url  = label_url_for(info["name"])
          label_text = "<a href=\"#{label_url}\">#{label}</a>"

          Kernel.format(HTML_GRAPH_ROW, {
            label_width: label_width,
            label_text: label_text,
            label_link: info["url"],
            percentage: width_percentage(info["total"], biggest),
            link_text: info["total"].to_s,
          })
        end

        def width_percentage(number_of_issues, biggest)
          number_of_issues * 100 / biggest
        end

        def url_suffix
          "issues"
        end

        def singular_type
          "issue"
        end

        def type
          singular_type + "s"
        end

        def pretty_type
          "issue"
        end

        def data
          return @data if instance_variable_defined?(:@data)

          fetcher = IssueFetcher.new(@repository, type, @start_date, @end_date)
          @data = fetcher.data
        end
      end
    end
  end
end
