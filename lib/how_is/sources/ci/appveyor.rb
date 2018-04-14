# frozen_string_literal: true

require "okay/http"
require "how_is/sources"

module HowIs::Sources
  module CI
    # Fetches metadata about CI builds from appveyor.com.
    class Appveyor
      # @param repository [String] GitHub repository name, of the format user/repo.
      # @param start_date [String] Start date for the report being generated.
      # @param end_date [String] End date for the report being generated.
      def initialize(repository, start_date, end_date)
        @repository = repository
        @start_date = start_date
        @end_date = end_date
        # TODO: Use start/end date.
        # TODO: Figure out default branch of the repo
      end

      # Fetches builds for the default branch.
      #
      # @return [Hash] Builds for the default branch.
      def builds
        fetch_builds
      rescue Net::HTTPServerException
        # It's not elegant, but it works™.
        []
      end

      private

      # Returns API result of /api/projects/:repository.
      #
      # @return [Hash] API results.
      def fetch_builds
        Okay::HTTP.get(
          "https://ci.appveyor.com/api/projects/#{@repository}",
          headers: {
            "Accept" => "application/json",
            "User-Agent" => HowIs::USER_AGENT,
          }
        ).or_raise!.from_json
      end
    end
  end
end
