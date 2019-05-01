# frozen_string_literal: true

require "okay/default"
require "okay/http"
require "inq/constants"
require "inq/sources"
require "inq/sources/github/contributions"
require "inq/text"

module Inq
  module Sources
    module CI
      # Fetches metadata about CI builds from appveyor.com.
      class Appveyor
        # @param repository [String] GitHub repository name, of the format user/repo.
        # @param start_date [String] Start date for the report being generated.
        # @param end_date   [String] End date for the report being generated.
        # @param cache      [Cacheable] Instance of Inq::Cacheable to cache API calls
        def initialize(config, start_date, end_date, cache)
          @config = config
          @cache = cache
          @repository = config["repository"]
          @start_date = DateTime.parse(start_date)
          @end_date = DateTime.parse(end_date)
          @default_branch = Okay.default
        end

        # @return [String] The default branch name.
        def default_branch
          return @default_branch unless @default_branch.nil?

          contributions = Sources::GitHub::Contributions.new(@config, nil, nil)

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
          @cache.cached("appveyor_builds") do
            Inq::Text.print "Fetching Appveyor build data."

            ret = Okay::HTTP.get(
              "https://ci.appveyor.com/api/projects/#{@repository}/history",
              parameters: {"recordsNumber" => "100"},
              headers: {
                "Accept" => "application/json",
                "User-Agent" => Inq::USER_AGENT,
              }
            ).or_raise!.from_json

            Inq::Text.puts
            ret
          end
        end
      end
    end
  end
end
