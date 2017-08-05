# frozen_string_literal: true

# Investigates who is a new committer since given date
#
#   # /repos/:owner/:repo/commits?since=<start date for the report>
class Contributions
  # @param github [Github] configured github client
  # @param since_date [String] A value which fits Repos.Commits "since" and
  #                            "until" fields. This supports many formats, for
  #                            example a timestamp in ISO 8601 format:
  #                            YYYY-MM-DDTHH:MM:SSZ.
  # @param user [String] GitHub user of repository
  # @param repo [String] GitHub repository name
  def initialize(github:, since_date:, user:, repo:)
    @github = github
    @since_date = since_date
    @user = user
    @repo = repo
  end

  # Returns a list of contributors that have zero commits before the @since_date.
  #
  # @return [Hash{String => Hash] Committers keyed by GitHub login name
  def new_contributors
    # author: GitHub login, name or email by which to filter by commit author.
    all_contributors.select do |email, _committer|
      @github.repos.commits.list(user: @user,
                                 repo: @repo,
                                 until: @since_date,
                                 author: email).count.zero?
    end
  end

  # @return [Hash{String => Hash}] Author information keyed by author's email
  def all_contributors
    commits.map { |api_response|
      [api_response.commit.author.email, api_response.commit.author.to_h]
    }.to_h
  end

  def commits
    @github.repos.commits.list(user: @user, repo: @repo, since: @since_date)
  end
end
