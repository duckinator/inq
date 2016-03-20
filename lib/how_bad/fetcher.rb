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
      issues: issues,
      pulls:  pulls,
    }
  end
end
