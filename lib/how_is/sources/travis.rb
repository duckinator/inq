# frozen_string_literal: true

require "okay/http"
require "how_is/sources/github"

module HowIs::Sources
  # Fetches metadata about CI builds from travis-ci.org.
  class Travis
    # @param repository [String] GitHub repository name, of the format user/repo.
    # @param end_date [String] End date for the report being generated.
    def initialize(repository, end_date)
      repository = @repository
      # TODO: Do something with end_date.
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
        "http://api.travis-ci.org/repos/#{@user}/#{@repo}/builds?event_type=push",
        headers: {"Accept" => "application/vnd.travis-ci.2+json"}
      ).body
    end
  end
end
