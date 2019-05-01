# frozen_string_literal: true

require "inq/sources/github/issues"

module Inq
  module Sources
    class Github
      ##
      # Fetches various information about GitHub Pull Requests
      class Pulls < Issues
        def url_suffix
          "pulls"
        end

        def singular_type
          "pull"
        end

        def type
          "pullRequests"
        end

        def pretty_type
          "pull request"
        end
      end
    end
  end
end
