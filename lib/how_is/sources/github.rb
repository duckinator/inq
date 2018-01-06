# frozen_string_literal: true

require "how_is"
require "how_is/sources"
require "github_api"
require "okay/graphql"

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
    end
  end
end
