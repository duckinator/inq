# frozen_string_literal: true

require "okay/http"
require "how_is/sources/github"

module HowIs::Sources
  class Github
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
        Okay::HTTP.get(
          "http://api.travis-ci.org/repos/#{@user}/#{@repo}/builds?event_type=push",
          headers: {"Accept" => "application/vnd.travis-ci.2+json"}
        ).body
      end
    end
  end
end
