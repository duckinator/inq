# frozen_string_literal: true

require "contracts"
require "github_api"
require "how_is/kludge_bucket"
require "how_is/contributions"

C ||= Contracts

class HowIs
  ##
  # Fetches data from GitHub.
  class Fetcher
    include Contracts::Core

    ##
    # Standardized representation for fetcher results.
    #
    # Implemented as a class instead of passing around a Hash so that it can
    # be more easily referenced by Contracts.
    Results = Struct.new(:repository, :issues, :pulls, :summary) do
      include Contracts::Core

      Contract String, C::ArrayOf[Hash], C::ArrayOf[Hash], String, String => nil
      def initialize(repository, issues, pulls, summary)
        super(repository, issues, pulls, summary)
      end

      # Struct defines #to_h, but not #to_hash, so we alias them.
      alias_method :to_hash, :to_h
    end

    ##
    # Fetches repository information from GitHub and returns a Results object.
    Contract String, String => Results
    def call(repository, end_date)
      user, repo = repository.split("/", 2)

      github = KludgeBucket.default_github_instance

      contributions = HowIs::Contributions.new(repository, end_date)

      unless repository
        raise HowIs::CLI::OptionsError, "To generate a report from GitHub, " \
          "provide the repository username/project. Quitting!"
      end

      issues  = github.issues.list user: user, repo: repo
      pulls   = github.pulls.list  user: user, repo: repo

      summary = contributions.summary

      Results.new(
        repository,
        obj_to_array_of_hashes(issues),
        obj_to_array_of_hashes(pulls),
        summary
      )
    end

    private

    def obj_to_array_of_hashes(object)
      object.to_a.map(&:to_h)
    end
  end
end
