require "contracts"
require "github_api"

class HowBad::Fetcher
  include Contracts::Core

  Contract String => {issues: C::Not[nil], pulls: C::Not[nil]}
  def call(repository)
    user, repo = repository.split('/', 2)
    github  = Github.new(auto_pagination: true)
    issues  = github.issues.list user: user, repo: repo
    pulls   = github.pulls.list  user: user, repo: repo

    {
      issues: to_array_of_hashes(issues),
      pulls:  to_array_of_hashes(pulls),
    }
  end

  private def to_array_of_hashes(object)
    object.to_a.map(&:to_h)
  end
end
