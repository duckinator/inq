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
        "https://github.com/#{repository}/#{type}"
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

      def to_s
        "TODO"
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
