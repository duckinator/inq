# frozen_string_literal: true

require "how_is/version"
require "how_is/sources/github"
require "how_is/sources/github_helpers"
require "date"

module HowIs::Sources
  class Github
    class Issues
      include HowIs::Sources::GithubHelpers

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
        raw_query = values.map {|k, v|
          [k, v].join(":")
        }.join(" ")

        query = CGI.escape(raw_query)

        "https://github.com/#{@repository}/#{url_suffix}?q=#{query}"
      end

      def average_age
        average_age_for(data)
      end

      def oldest
        oldest_for(data) || {}
      end

      def newest
        newest_for(data) || {}
      end

      def summary
        number_open = to_a.length
        pretty_number =
          pluralize(pretty_type, number_open, zero_is_no: true)

        "There #{are_or_is(number_open)} <a href=\"#{url}\">#{pretty_number} open</a>."
      end

      def to_html
        summary_ = "<p>#{summary}</p>"

        return summary_ if to_a.empty?

        template_data = {
          summary: summary_,
          average_age: average_age,
          type: type,
          pretty_type: pretty_type,

          oldest_link: oldest["url"],
          oldest_date: pretty_date(oldest["createdAt"]),

          newest_link: newest["url"],
          newest_date: pretty_date(newest["createdAt"]),
        }

        Kernel.format(HowIs.template("issues_or_pulls_partial.html_template"), template_data)
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
          # TODO: Remove this hack to get around unlabeled issues not having a link.
          label_text = label
          label_url  = label_url_for(info["name"])
          label_text = '<a href="' + label_url + '">' + label_text + '</a>'

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

      def fetch_last_cursor
        query = Okay::GraphQL.query <<~QUERY
          repository(owner: #{@user.inspect}, name: #{@repo.inspect}) {
            #{type}(last: 1, orderBy:{field: CREATED_AT, direction: ASC}) {
              edges {
                cursor
              }
            }
          }
        QUERY

        headers = { bearer_token: HowIs::Sources::Github::ACCESS_TOKEN }
        raw_data = query.submit!(:github, headers).or_raise!.from_json

        edges = raw_data.dig("data", "repository", type, "edges")
        if edges.nil? || edges.length == 0
          nil
        else
          edges.last["cursor"]
        end
      end

      def data
        return @data if instance_variable_defined?(:@data)

        @data = []
        last_cursor = fetch_last_cursor
        return @data if last_cursor.nil?

        begin
          after = fetch_issues(after, last_cursor)
        end until after.nil?

        @data.select! { |issue|
          if !issue["closedAt"].nil? && date_le(issue["closedAt"], @start_date)
            false
          else
            date_ge(issue["createdAt"], @start_date) && date_le(issue["createdAt"], @end_date)
          end
        }

        @data
      end

      def fetch_issues(after, last_cursor)
        chunk_size = 100
        after_str = ", after: #{after.inspect}" unless after.nil?

        query = Okay::GraphQL.query <<~QUERY
          repository(owner: #{@user.inspect}, name: #{@repo.inspect}) {
            #{type}(first: #{chunk_size}#{after_str}, orderBy:{field: CREATED_AT, direction: ASC}) {
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

        headers = { bearer_token: HowIs::Sources::Github::ACCESS_TOKEN }
        raw_data = query.submit!(:github, headers).or_raise!.from_json
        edges = raw_data.dig("data", "repository", type, "edges")

        current_last_cursor = edges.last["cursor"]

        unless edges.nil?
          new_data = edges.map { |issue|
            node = issue["node"]
            node["labels"] = node["labels"]["nodes"]

            node
          }

          @data += new_data
        end

        if current_last_cursor == last_cursor
          nil
        else
          current_last_cursor
        end
      end

      private

      def date_le(left, right)
        left  = str_to_dt(left)
        right = str_to_dt(right)

        left <= right
      end

      def date_ge(left, right)
        left  = str_to_dt(left)
        right = str_to_dt(right)

        left >= right
      end

      def str_to_dt(str)
        DateTime.parse(str)
      end
    end
  end
end
