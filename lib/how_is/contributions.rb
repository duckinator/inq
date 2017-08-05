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

  # Returns a list of committers that have zero commits before the @date.
  #
  # @return [Hash{String => Hash] Committers keyed by GitHub login name
  def new_committers
    committers_by_email = {}
    @github.repos.commits.list(user: @user, repo: @repo, since: @since_date) do |commit|
      committers_by_email[commit.author.login] = commit.author
    end

    # author: GitHub login, name or email by which to filter by commit author.
    committers_by_email.select do |login, _committer|
      @github.repos.commits.list(user: @user,
                                 repo: @repo,
                                 until: @since_date,
                                 author: login).count.zero?
    end
  end
end
