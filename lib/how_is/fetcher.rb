require 'contracts'
require 'github_api'

##
# Fetches data from GitHub.
class HowIs::Fetcher
  include Contracts::Core

  ##
  # Standardized representation for fetcher results.
  #
  # Implemented as a class instead of passing around a Hash so that it can
  # be more easily referenced by Contracts.
  class Results < Struct.new(:repository, :issues, :pulls)
    include Contracts::Core

    Contract String, C::ArrayOf[Hash], C::ArrayOf[Hash] => nil
    def initialize(repository, issues, pulls)
      super(repository, issues, pulls)
    end

    # Struct defines #to_h, but not #to_hash, so we alias them.
    alias_method :to_hash, :to_h
  end


  Contract String, C::RespondTo[:issues, :pulls] => Results
  def call(repository,
        github = nil)
    github ||= Github.new(auto_pagination: true)
    user, repo = repository.split('/', 2)
    issues  = github.issues.list user: user, repo: repo
    pulls   = github.pulls.list  user: user, repo: repo

    Results.new(
      repository,
      obj_to_array_of_hashes(issues),
      obj_to_array_of_hashes(pulls)
    )
  end

  private def obj_to_array_of_hashes(object)
    object.to_a.map(&:to_h)
  end
end
