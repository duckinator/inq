# frozen_string_literal: true

require "how_is"
require "how_is/sources"
require "github_api"
require "graphql/client"

module HowIs
  module Sources
    class Github
      BASIC_AUTH    = ENV["HOWIS_BASIC_AUTH"]
      ACCESS_TOKEN  = ENV["HOWIS_GITHUB_TOKEN"]

      # Used for the the Authorization header when talking to the
      # GitHub API.
      # https://developer.github.com/v4/guides/forming-calls/#communicating-with-graphql
      AUTHORIZATION_HEADER =
        if ACCESS_TOKEN
          "bearer " + ACCESS_TOKEN
        else
          nil
        end

      def self.rest
        @rest_client ||= build_rest_client
      end

      def self.graphql
        @graphql_client ||= build_graphql_client
      end


      def self.build_rest_client
        ::Github.new(auto_pagination: true) do |config|
          config.basic_auth = BASIC_AUTH
        end
      end


      def self.build_graphql_client
        http =
          GraphQL::Client::HTTP.new("https://api.github.com/graphql") {
            def headers(context)
              {
                "Authorization" => AUTHORIZATION_HEADER
              }
            end
        }
        schema = GraphQL::Client.load_schema(http)

        GraphQL::Client.new(schema: schema, execute: http)
      end

    end
  end
end
