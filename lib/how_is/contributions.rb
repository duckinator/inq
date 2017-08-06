# frozen_string_literal: true

class HowIs
  # Fetch information about who has contributed to a repository during a given
  # period.
  #
  # Usage:
  #
  #     github = Github.new()
  #     c = HowIs::Contributions.new(github: github, start_date: '2017-07-01', user: 'how-is', repo: 'how_is')
  #     c.commits          #=> All commits during July 2017.
  #     c.all_contributors #=> All contributors during July 2017.
  #     c.new_contributors #=> New contributors during July 2017.
  class Contributions
    # Returns an object that fetches contributor information about a particular
    # repository for a month-long period starting on +start_date+.
    #
    # @param github [Github] Github client instance.
    # @param start_date [String] Date in the format YYYY-MM-DD. The first date
    #                            to include commits from.
    # @param user [String] GitHub user of repository.
    # @param repo [String] GitHub repository name.
    def initialize(github:, start_date:, user:, repo:)
      @github = github

      # IMPL. DETAIL: The external API uses "start_date" so it's clearer,
      #               but internally we use "since_date" to match GitHub's API.

      @since_date = Date.strptime(start_date, "%Y-%m-%d")

      d = @since_date.day
      m = @since_date.month
      y = @since_date.year
      @until_date = Date.new(y, m + 1, d)

      @user = user
      @repo = repo
    end

    # Returns a list of contributors that have zero commits before the @since_date.
    #
    # @return [Hash{String => Hash] Committers keyed by GitHub login name
    def new_contributors
      # author: GitHub login, name or email by which to filter by commit author.
      all_contributors.select do |email, _committer|
        # Returns true if +email+ never wrote a commit for +@repo+ before +@since_date+.
        @github.repos.commits.list(user: @user,
                                   repo: @repo,
                                   until: @since_date,
                                   author: email).count.zero?
      end
    end

    # @return [Hash{String => Hash}] Author information keyed by author's email.
    def all_contributors
      commits.map { |api_response|
        [api_response.commit.author.email, api_response.commit.author.to_h]
      }.to_h
    end

    def commits_for_branch(branch)
      # ???
    end

    def commits
      @commits ||= @github.repos.commits.list(user: @user, repo: @repo, since: @since_date)
    end

    def default_branch
      '??? main branch ???'
    end

    def changed_files
      ['??? changed files ???']
    end

    def total_additions
      -1 # TODO
    end

    def total_deletions
      -1 # TODO
    end

    def compare_url
      since_timestamp = @since_date.to_time.to_i
      until_timestamp = @until_date.to_time.to_i
      "https://github.com/#{@user}/#{@repo}/compare/#{default_branch}@%7B#{since_timestamp}%7D...#{default_branch}@%7B#{until_timestamp}%7D"
    end

    def summary
      # TODO: Pulse has information about _all_ branches. Do we want that?
      #       If we do, we'd need to pass a branch name as the 'sha' parameter
      #       to /repos/:owner/:repo/commits.
      #       https://developer.github.com/v3/repos/commits/

      p commits.first
      <<~EOF
        Excluding merges, <strong>#{all_contributors.length} authors</strong>
        <strong>#{commits.length} commits</strong> have been made.
        A total of #{changed_files} files changed, and there have been
        <a href="#{compare_url}">
        <strong>#{total_additions} additions</strong> and
        <strong>#{total_deletions} deletions</strong></a>.
      EOF
    end
  end
end
