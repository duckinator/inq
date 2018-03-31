# frozen_string_literal: true

require "okay/default"
require "okay/http"
require "how_is/sources/github"

module HowIs::Sources
  module CI
    # Fetches metadata about CI builds from travis-ci.org.
    class Travis
      BadResponseError = Class.new(StandardError)

      # @param repository [String] GitHub repository name, of the format user/repo.
      # @param start_date [String] Start date for the report being generated.
      # @param end_date [String] End date for the report being generated.
      def initialize(repository, start_date, end_date)
        @repository = repository
        @start_date = start_date
        @end_date = end_date
        @default_branch = Okay.default
        # TODO: Use start/end date.
      end

      # @return [String] The default branch name.
      def default_branch
        return @default_branch unless @default_branch == Okay.default

        response = fetch("branches", {"sort_by" => "default_branch"})

        # Fail if +response+ isn't a Hash.
        unless response.is_a?(Hash)
          raise BadResponseError, "expected `response' to be a Hash, got #{response.class}."
        end

        # Fail if +response+ is a Hash, but doesn't have the key +"branches"+.
        unless response.has_key?("branches")
          raise BadResponseError, "expected `response' to have key `\"branches\"'"
        end

        branches = response["branches"]

        # Fail if +branches+ is an Array, but not an Array of Hashes.
        unless branches.all? { |branch| branch.is_a?(Hash) }
          classes = branches.map(&:class).sort.uniq
          raise BadResponseError, "expected Array of Hashes, got Array containing: #{classes.inspect}."
        end

        branch = branches.find { |b| b["default_branch"] == true }
        if branch
          @default_branch = branch["name"]
        else
          @default_branch = nil
        end
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
