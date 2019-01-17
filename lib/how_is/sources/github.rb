# frozen_string_literal: true

require "how_is/version"
require "how_is/sources"
require "okay/graphql"

module HowIs
  module Sources
    # Contains configuration information for GitHub-based sources.
    class Github
      class ConfigError < StandardError
      end

      def initialize(global_config)
        raise ConfigError, "Expected Hash, got #{global_config.class}." unless \
          global_config.is_a?(Hash)

        raise ConfigError, "No config for sources/github." unless \
          global_config.has_key?("sources/github")

        config = global_config["sources/github"]

        raise ConfigError, "No username provided for sources/github." unless \
          config.has_key?("username") && config["username"]

        raise ConfigError, "No token provided for sources/github." unless \
          config.has_key?("token") && config["token"]

        @global_config = global_config
        @config = config
      end

      # The GitHub username used for authenticating with GitHub.
      def username
        @config["username"]
      end

      # A GitHub Personal Access Token which goes with +username+.
      def access_token
        @config["token"]
      end

      # A string containing both the GitHub username and access token,
      # used in instances where we use Basic Auth.
      def basic_auth
        "#{username}:#{access_token}"
      end

      def graphql(query_string)
        Okay::GraphQL.query(query_string)
          .submit!(:github, {bearer_token: access_token})
          .or_raise!
          .from_json
      end
    end
  end
end
