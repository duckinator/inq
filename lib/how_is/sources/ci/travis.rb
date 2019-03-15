# frozen_string_literal: true

require "date"
require "okay/default"
require "okay/http"
require "how_is/constants"
require "how_is/sources/github"
require "how_is/text"

module HowIs
  module Sources
    module CI
      # Fetches metadata about CI builds from travis-ci.org.
      class Travis
        BadResponseError = Class.new(StandardError)

        # @param repository [String] GitHub repository name, of the format user/repo.
        # @param start_date [String] Start date for the report being generated.
        # @param end_date [String] End date for the report being generated.
        def initialize(config, start_date, end_date)
          @config = config
          @repository = config["repository"]
          raise "Travis.new() got nil repository." if @repository.nil?
          @start_date = DateTime.parse(start_date)
          @end_date = DateTime.parse(end_date)
          @default_branch = Okay.default
        end

        # @return [String] The default branch name.
        def default_branch
          return @default_branch unless @default_branch == Okay.default

          response = fetch("branches", {"sort_by" => "default_branch"})
          validate_response!(response)

          branches = response["branches"]
          validate_branches!(branches)

          branch = branches.find { |b| b["default_branch"] == true }
          @default_branch = branch&.fetch("name", nil)
        end

        # Returns the builds for the default branch.
        #
        # @return [Hash] Hash containing the builds for the default branch.
        def builds
          raw_builds \
            .map(&method(:normalize_build)) \
            .select(&method(:in_date_range?)) \
            .map(&method(:add_build_urls))
        end

        private

        def add_build_urls(build)
          build["html_url"] = "https://travis-ci.org/#{build['repository']}#{build['@href']}"
          build
        end

        def validate_response!(response)
          return true if hash_with_key?(response, "branches")

          raise BadResponseError,
            "expected `response' (#{response.class}) to be a Hash with key `\"branches\"'."
        end

        def validate_branches!(branches)
          return true if array_of_hashes?(branches)

          raise BadResponseError, "expected `branches' to be Array of Hashes."
        end

        def array_of_hashes?(ary)
          ary.is_a?(Array) && ary.all? { |obj| obj.is_a?(Hash) }
        end

        def hash_with_key?(hsh, key)
          hsh.is_a?(Hash) && hsh.has_key?(key)
        end

        def in_date_range?(build, start_date = @start_date, end_date = @end_date)
          (build["started_at"] >= start_date) \
            && (build["finished_at"] <= end_date)
        end

        def raw_builds
          results = fetch("builds", {
            "event_type" => "push",
            "branch.name" => default_branch,
          })

          results["builds"] || {}
        rescue Net::HTTPServerException
          # It's not elegant, but it works™.
          {}
        end

        def normalize_build(build)
          build_keys = ["@href", "pull_request_title", "pull_request_number",
                        "started_at", "finished_at", "repository", "commit",
                        "jobs"]
          result = pluck_keys(build, build_keys)

          commit_keys = ["sha", "ref", "message", "compare_url",
                         "committed_at", "jobs"]
          result["commit"] = pluck_keys(result["commit"], commit_keys)

          job_keys = ["href", "id"]
          result["jobs"] = result["jobs"].map { |j| pluck_keys(j, job_keys) }

          result["repository"] = result["repository"]["slug"]

          ["started_at", "finished_at"].each do |k|
            result[k] = DateTime.parse(result[k])
          end

          result
        end

        def pluck_keys(hsh, keys)
          keys.map { |k| [k, hsh[k]] }.to_h
        end

        # Returns API results for /repos/:user/:repo/<path>.
        #
        # @param path [String] Path suffix (appended to /repo/<repo name>/).
        # @param parameters [Hash] Parameters.
        # @return [String] JSON result.
        def fetch(path, parameters = {})
          HowIs::Text.print "Fetching Travis CI #{path.sub(/e?s$/, '')} data."

          # Apparently this is required for the Travis CI API to work.
          repo = @repository.sub("/", "%2F")

          ret = Okay::HTTP.get(
            "https://api.travis-ci.org/repo/#{repo}/#{path}",
            parameters: parameters,
            headers: {
              "Travis-Api-Version" => "3",
              "Accept" => "application/json",
              "User-Agent" => HowIs::USER_AGENT,
            }
          ).or_raise!.from_json

          HowIs::Text.puts

          ret
        end
      end
    end
  end
end
