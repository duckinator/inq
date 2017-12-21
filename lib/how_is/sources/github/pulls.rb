# frozen_string_literal: true

require "how_is/version"
require "how_is/sources/github"
require "how_is/sources/github_helpers"
require "date"

module HowIs::Sources
  class Github
    class Pulls < Issues
      def type
        "pulls"
      end

      def pretty_type
        "pull request"
      end
    end
  end
end
