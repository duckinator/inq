# frozen_string_literal: true

require "okay/http"
require "how_is/sources/github"

module HowIs::Sources
  # Fetches metadata about CI builds from travis-ci.org.
  class Travis
    # @param repository [String] GitHub repository name, of the format user/repo.
    # @param start_date [String] Start date for the report being generated.
    # @param end_date [String] End date for the report being generated.
    def initialize(repository, start_date, end_date)
      @repository = repository
      @start_date = start_date
      @end_date = end_date
      # TODO: Use start/end date.
      # TODO: Figure out Default Branch of the repo
    end

    def builds
      JSON.parse(fetch_builds)
    end

    private

    # Returns API result of /repos/:user/:repo/builds for Push type Travis
    # events.
    #
    # @return [String] JSON result
    def fetch_builds
      Okay::HTTP.get(
        "http://api.travis-ci.org/repos/#{@repository}/builds?event_type=push",
        headers: {"Accept" => "application/vnd.travis-ci.2+json"}
      ).body
    end
  end
end
