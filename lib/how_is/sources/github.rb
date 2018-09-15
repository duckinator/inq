# frozen_string_literal: true

require "how_is/version"
require "how_is/sources"
require "github_api"
require "okay/graphql"

module HowIs
  module Sources
    # Contains configuration information for GitHub-based sources.
    class Github
      # An exception which is only raised if an environment variable
      # is undefined.
      class ConfigurationError < StandardError
        def initialize(env_variable)
          super("environment variable #{env_variable} not defined." \
                  " See README.md for details.")
        end
      end

      # A GitHub Personal Access Token.
      def self.access_token
        token = ENV["HOWIS_GITHUB_TOKEN"]
        raise ConfigurationError, "HOWIS_GITHUB_TOKEN" if token.nil?

        token
      end

      # "<github username>:<personal access token>"
      def self.basic_auth
        auth = ENV["HOWIS_BASIC_AUTH"]
        raise ConfigurationError, "HOWIS_BASIC_AUTH" if auth.nil?

        auth
      end

      def self.graphql(query_string)
        query = Okay::GraphQL.query(query_string)
        headers = {bearer_token: HowIs::Sources::Github.access_token}
        query.submit!(:github, headers).or_raise!.from_json
      end
    end
  end
end
