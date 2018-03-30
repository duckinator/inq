# frozen_string_literal: true

require "okay/http"
require "how_is/sources/github"

module HowIs::Sources
  module CI
    # Fetches metadata about CI builds from travis-ci.org.
    class Travis
      # @param repository [String] GitHub repository name, of the format user/repo.
      # @param start_date [String] Start date for the report being generated.
      # @param end_date [String] End date for the report being generated.
      def initialize(repository, start_date, end_date)
        @repository = repository
        @start_date = start_date
        @end_date = end_date
        @default_branch = :default
        # TODO: Use start/end date.
      end

      # @return [String] The default branch name.
      def default_branch
        return @default_branch unless @default_branch == :default

        sorted_branches = fetch("branches", {"sort_by" => "default_branch"})
        @default_branch = sorted_branches["branches"]&.first["name"]
      end

      # Returns the builds for the default branch.
      #
      # @return [Hash] Hash containing the builds for the default branch.
      def builds
        fetch("builds", {
          "event_type" => "push",
          "branch.name" => default_branch,
        })
      rescue Net::HTTPServerException
        # It's not elegant, but it works™.
        {}
      end

      private

      # Returns API results for /repos/:user/:repo/<path>.
      #
      # @param path [String] Path suffix (appended to /repo/<repo name>/).
      # @param parameters [Hash] Parameters.
      # @return [String] JSON result.
      def fetch(path, parameters = {})
        # Apparently this is required for the Travis CI API to work.
        repo = @repository.sub('/', '%2F')

        Okay::HTTP.get(
          "https://api.travis-ci.org/repo/#{repo}/#{path}",
          parameters: parameters,
          headers: {
            "Travis-Api-Version" => "3",
            "Accept" => "application/json",
            "User-Agent" => HowIs::USER_AGENT,
          },
        ).or_raise!.from_json
      end
    end
  end
end
