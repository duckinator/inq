# frozen_string_literal: true

require "how_is/fetcher"

class HowIs
  # Fetches metadata about CI builds.
  #
  # Supports Travis
  class Builds
    # @param user [String] GitHub user of repository.
    # @param repo [String] GitHub repository name.
    def initialize(user:, repo:)
      @user = user
      @repo = repo
      # TODO: Figure out Default Branch of the repo
    end

    def summary
      JSON.parse(travis_builds)
    end

    # Returns API result of /repos/:user/:repo/builds for Push type Travis
    # events.
    #
    # @return [String] JSON result
    def travis_builds
      Tessellator::Fetcher::Request::HTTP.call(
        Tessellator::Fetcher::Config.new,
        "get",
        "http://api.travis-ci.org/repos/#{@user}/#{@repo}/builds?event_type=push",
        {},
        headers: {"Accept" => "application/vnd.travis-ci.2+json"}
      ).body
    end
  end
end
