# frozen_string_literal: true

require "how_is/fetcher"

class HowIs
  # Fetch information about who has contributed to a repository during a given
  # period.
  #
  # Usage:
  #
  #     github = Github.new()
  #     c = HowIs::Contributions.new(github: github, start_date: '2017-07-01', user: 'how-is', repo: 'how_is')
  #     c.commits          #=> All commits during July 2017.
  #     c.contributors #=> All contributors during July 2017.
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
    def initialize(github: Fetcher.default_github_instance, start_date:, user:, repo:)
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
      @new_contributors ||= contributors.select do |email, _committer|
        # Returns true if +email+ never wrote a commit for +@repo+ before +@since_date+.
        @github.repos.commits.list(user: @user,
                                   repo: @repo,
                                   until: @since_date,
                                   author: email).count.zero?
      end
    end

    # @return [Hash{String => Hash}] Author information keyed by author's email.
    def contributors
      commits.map { |api_response|
        [api_response.commit.author.email, api_response.commit.author.to_h]
      }.to_h
    end

    def commits
      return @commits unless @commits.nil?

      commits = @github.repos.commits.list(user: @user, repo: @repo, since: @since_date)

      # The commits list endpoint doesn't include all commit data, e.g. stats.
      # So, we make N requests here, where N == number of commits returned,
      # and then we die a bit inside.
      @commits = commits.map { |c| commit(c.sha) }
    end

    def commit(sha)
      @commit ||= {}
      @commit[sha] ||= @github.repos.commits.get(user: @user, repo: @repo, sha: sha)
    end

    def changes
      if @stats.nil? || @changed_files.nil?
        @stats = {
          "total" => 0,
          "additions" => 0,
          "deletions" => 0,
        }

        @changed_files = []

        commits.map do |commit|
          commit.stats.each do |k, v|
            @stats[k] += v
          end

          @changed_files += commit.files.map { |file| file["filename"] }
        end

        @changed_files.sort.uniq!
      end

      {"stats" => @stats, "files" => @changed_files}
    end

    # TODO: Don't hard-code the default branch.
    def default_branch
      "master"
    end

    def changed_files
      changes["files"]
    end

    def additions_count
      changes["stats"]["additions"]
    end

    def deletions_count
      changes["stats"]["deletions"]
    end

    def compare_url
      since_timestamp = @since_date.to_time.to_i
      until_timestamp = @until_date.to_time.to_i
      "https://github.com/#{@user}/#{@repo}/compare/#{default_branch}@%7B#{since_timestamp}%7D...#{default_branch}@%7B#{until_timestamp}%7D"
    end

    def pretty_start_date
      @since_date.strftime("%b %d, %Y")
    end

    def pretty_end_date
      @until_date.strftime("%b %d, %Y")
    end

    def summary(start_text: nil)
      # TODO: Pulse has information about _all_ branches. Do we want that?
      #       If we do, we'd need to pass a branch name as the 'sha' parameter
      #       to /repos/:owner/:repo/commits.
      #       https://developer.github.com/v3/repos/commits/

      start_text ||= "From #{pretty_start_date} through #{pretty_end_date}"

      "#{start_text}, #{@user}/#{@repo} gained "\
        "<a href=\"#{compare_url}\">#{pluralize('new commit', commits.length)}</a>, " \
        "contributed by #{pluralize("author", contributors.length)}. There " \
        "#{(additions_count == 1) ? "was" : "were"} " \
        "#{pluralize('addition', additions_count)} and " \
        "#{pluralize('deletion', deletions_count)} across " \
        "#{pluralize('file', changed_files.length)}."
    end

    private

    def pluralize(string, number)
      "#{number} #{string}#{(number == 1) ? '' : 's'}"
    end
  end
end
