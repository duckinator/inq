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

      def initialize(config)
        must_have_key!(config, "sources/github")

        @config = config["sources/github"]

        must_have_key!(@config, "username")
        must_have_key!(@config, "token")
      end

      def must_have_key!(hash, key)
        raise ConfigError, "Expected Hash, got #{hash.class}" unless hash.is_a?(Hash)
        raise ConfigError, "Expected key `#{key}'" unless hash.has_key?(key)
      end
      private :must_have_key!

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
