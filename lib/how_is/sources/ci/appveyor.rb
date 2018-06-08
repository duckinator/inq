# frozen_string_literal: true

require "okay/default"
require "okay/http"
require "how_is/sources"
require "how_is/sources/github/contributions"

module HowIs
  module Sources
    module CI
      # Fetches metadata about CI builds from appveyor.com.
      class Appveyor
        # @param repository [String] GitHub repository name, of the format user/repo.
        # @param start_date [String] Start date for the report being generated.
        # @param end_date [String] End date for the report being generated.
        def initialize(repository, start_date, end_date)
          @repository = repository
          @start_date = DateTime.parse(start_date)
          @end_date = DateTime.parse(end_date)
          @default_branch = Okay.default
        end

        # @return [String] The default branch name.
        def default_branch
          return @default_branch unless @default_branch.nil?

          contributions =
            HowIs::Sources::GitHub::Contributions.new(repository, nil, nil)

          @default_branch = contributions.default_branch
        end

        # Fetches builds for the default branch.
        #
        # @return [Hash] Builds for the default branch.
        def builds
          @builds ||=
            fetch_builds["builds"] \
              .map(&method(:normalize_build)) \
              .select(&method(:in_date_range?))
        rescue Net::HTTPServerException
          # It's not elegant, but it works™.
          []
        end

        private

        def in_date_range?(build)
          build["started_at"] >= @start_date &&
            build["started_at"] <= @end_date
        end

        def normalize_build(build)
          build["started_at"] = DateTime.parse(build["created"])
          build["html_url"] = "https://ci.appveyor.com/project/#{@repository}/build/#{build['buildNumber']}"
          build
        end

        # Returns API result of /api/projects/:repository.
        # FIXME: This doesn't limit results based on the date range.
        #
        # @return [Hash] API results.
        def fetch_builds
          Okay::HTTP.get(
            "https://ci.appveyor.com/api/projects/#{@repository}/history",
            parameters: {"recordsNumber" => "100"},
            headers: {
              "Accept" => "application/json",
              "User-Agent" => HowIs::USER_AGENT,
            }
          ).or_raise!.from_json
        end
      end
    end
  end
end
