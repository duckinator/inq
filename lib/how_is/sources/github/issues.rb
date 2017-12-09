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

          oldest_link: oldest[:link],
          oldest_date: oldest[:creation_date],

          newest_link: newest[:link],
          newest_date: newest[:creation_date],
        }

        Kernel.format(HowIs.template("issues_or_pulls_partial.html_template"), template_data)
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
