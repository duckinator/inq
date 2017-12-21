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
        pretty_number = (to_a.length == 0) ? "no" : to_a.length

        "There are <a href=\"#{url}\">#{pretty_number} #{pretty_type} open</a>."
      end

      def to_html
        fetch!

        summary_ = "<p>#{summary}</p>"

        return summary_ if to_a.length == 0

        template_data = {
          summary: summary_,
          average_age: average_age,
          type: type,
          pretty_type: pretty_type,

          oldest_link: oldest[:link],
          oldest_date: oldest[:creation_date],

          newest_link: newest[:link],
          newest_date: newest[:creation_date],
        }

        Kernel.format(HowIs.template("issues_or_pulls_partial.html_template"), template_data)
      end

      # TODO: Clean up Issues Per Label stuff, or replace it with different functionality.

      def issues_per_label
        ipl = with_label_links(num_with_label(@data), @repository)
        number_with_no_label = num_with_no_label(@data)

        if number_with_no_label >0
          ipl["(No label)"] = {
            "link"  => nil,
            "total" => number_with_no_label
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

        biggest = data.map { |label, info| info["total"] }.max
        get_percentage = ->(number_of_issues) { number_of_issues * 100 / biggest }

        longest_label_length = data.map(&:first).map(&:length).max
        label_width = "#{longest_label_length}ch"

        parts = data.map { |label, info|
          Kernel.format(HTML_GRAPH_ROW, {
            label_width: label_width,
            label_text: label,
            percentage: get_percentage.call(info["total"]),
            link_text: info["link"],
          })
        }

        "<table class=\"horizontal-bar-graph\">\n" +
        parts.join("\n") +
        "</table>\n"
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
        type
      end

      def fetch!
        @data ||= HowIs.github.send(type).list(user: @user, repo: @repo)
      end
    end
  end
end
