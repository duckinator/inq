# frozen_string_literal: true

require "how_is/version"
require "how_is/date_time_helpers"
require "how_is/sources/github"
require "how_is/sources/github_helpers"
require "date"

module HowIs
  module Sources
    class Github
      ##
      # Fetches various information about GitHub Issues.
      class Issues
        include HowIs::DateTimeHelpers
        include HowIs::Sources::GithubHelpers

        END_LOOP = :terminate_graphql_loop

        GRAPHQL_QUERY = <<~QUERY
          repository(owner: %{user}, name: %{repo}) {
            %{type}(first: %{chunk_size}%{after_str}, orderBy:{field: CREATED_AT, direction: ASC}) {
              edges {
                cursor
                node {
                  number
                  createdAt
                  closedAt
                  updatedAt
                  state
                  title
                  url
                  labels(first: 100) {
                    nodes {
                      name
                    }
                  }
                }
              }
            }
          }
        QUERY

        CHUNK_SIZE = 100

        def initialize(repository, start_date, end_date)
          @repository = repository
          @user, @repo = repository.split("/", 2)
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

          template_data = {
            summary: summary,
            average_age: average_age,
            pretty_type: pretty_type,

            oldest_link: oldest["url"],
            oldest_date: oldest["date"],

            newest_link: newest["url"],
            newest_date: newest["date"],
          }

          HowIs.apply_template("issues_or_pulls_partial", template_data)
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
          get_percentage = ->(number_of_issues) { number_of_issues * 100 / biggest }

          longest_label_length = ipl.map(&:first).map(&:length).max
          label_width = "#{longest_label_length}ch"

          parts = ipl.map { |label, info|
            label_url  = label_url_for(info["name"])
            label_text = "<a href=\"#{label_url}\">#{label}</a>"

            Kernel.format(HTML_GRAPH_ROW, {
              label_width: label_width,
              label_text: label_text,
              label_link: info["url"],
              percentage: get_percentage.call(info["total"]),
              link_text: info["total"].to_s,
            })
          }

          "<table class=\"horizontal-bar-graph\">\n" +
          parts.join("\n") +
          "\n</table>"
        end

        def to_a
          obj_to_array_of_hashes(data)
        end

        private

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

          @data = []
          return @data if last_cursor.nil?

          after = nil
          data = []
          after, data = fetch_issues(after, data) until after == END_LOOP

          @data = data.select(&method(:issue_is_relevant?))
        end

        def issue_is_relevant?(issue)
          if !issue["closedAt"].nil? && date_le(issue["closedAt"], @start_date)
            false
          else
            date_ge(issue["createdAt"], @start_date) && date_le(issue["createdAt"], @end_date)
          end
        end

        def last_cursor
          return @last_cursor if instance_variable_defined?(:@last_cursor)

          raw_data = Github.graphql <<~QUERY
            repository(owner: #{@user.inspect}, name: #{@repo.inspect}) {
              #{type}(last: 1, orderBy:{field: CREATED_AT, direction: ASC}) {
                edges {
                  cursor
                }
              }
            }
          QUERY

          edges = raw_data.dig("data", "repository", type, "edges")
          @last_cursor =
            if edges.nil? || edges.empty?
              nil
            else
              edges.last["cursor"]
            end
        end

        def fetch_issues(after, data)
          after_str = ", after: #{after.inspect}" unless after.nil?

          query = build_query(@user, @repo, type, after_str)
          raw_data = Github.graphql(query)
          edges = raw_data.dig("data", "repository", type, "edges")

          data += edge_nodes(edges)

          next_cursor = edges.last["cursor"]
          next_cursor = END_LOOP if next_cursor == last_cursor

          [next_cursor, data]
        end

        def build_query(user, repo, type, after_str)
          format(GRAPHQL_QUERY, {
            user: user.inspect,
            repo: repo.inspect,
            type: type,
            chunk_size: CHUNK_SIZE,
            after_str: after_str,
          })
        end

        def edge_nodes(edges)
          return [] if edges.nil?
          new_data = edges.map { |issue|
            node = issue["node"]
            node["labels"] = node["labels"]["nodes"]

            node
          }

          new_data
        end
      end
    end
  end
end
