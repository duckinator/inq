require "github_api"

class HowIs
  # A big ol' steaming pile of shit.
  module KludgeBucket
    # TODO: Fix this bullshit.
    # :nodoc:
    def self.default_github_instance
      Github.new(auto_pagination: true) do |config|
        config.basic_auth = ENV["HOWIS_BASIC_AUTH"] if ENV["HOWIS_BASIC_AUTH"]
      end
    end
  end
end
