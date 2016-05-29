require "contracts"
require "github_api"

class HowBad::Fetcher
  include Contracts::Core

  Contract String, C::Any => {issues: C::Not[nil], pulls: C::Not[nil]}
  def call(repository,
        github = Github.new(auto_pagination: true))
    user, repo = repository.split('/', 2)
    issues  = github.issues.list user: user, repo: repo
    pulls   = github.pulls.list  user: user, repo: repo

    {
      issues: obj_to_array_of_hashes(issues),
      pulls:  obj_to_array_of_hashes(pulls),
    }
  end

  private def obj_to_array_of_hashes(object)
    object.to_a.map(&:to_h)
  end
end
