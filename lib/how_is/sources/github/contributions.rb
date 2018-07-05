# frozen_string_literal: true

require "how_is/version"
require "how_is/sources/github"
require "how_is/sources/github_helpers"
require "date"

module HowIs
  module Sources
    class Github
      # Fetch information about who has contributed to a repository during a given
      # period.
      #
      # Usage:
      #
      #     c = HowIs::Contributions.new(start_date: '2017-07-01', user: 'how-is', repo: 'how_is')
      #     c.commits          #=> All commits during July 2017.
      #     c.contributors #=> All contributors during July 2017.
      #     c.new_contributors #=> New contributors during July 2017.
      class Contributions
        include HowIs::Sources::GithubHelpers

        # Returns an object that fetches contributor information about a particular
        # repository for a month-long period starting on +start_date+.
        #
        # @param repository [String] GitHub repository in the form of "user/repo".
        # @param start_date [String] Date in the format YYYY-MM-DD. The first date
        #                            to include commits from.
        # @param end_date [String] Date in the format YYYY-MM-DD. The last date
        #                          to include commits from.
        def initialize(repository, start_date, end_date)
          @user, @repo = repository.split("/")
          @github = ::Github.new(auto_pagination: true) do |config|
            config.basic_auth = HowIs::Sources::Github::BASIC_AUTH
          end

          # IMPL. DETAIL: The external API uses "end_date" so it's clearer,
          #               but internally we use "until_date" to match GitHub's API.
          @since_date = start_date
          @until_date = end_date

          @commit = {}
          @stats = nil
          @changed_files = nil
        end

        # Returns a list of contributors that have zero commits before the @since_date.
        #
        # @return [Hash{String => Hash}] Contributors keyed by email
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
          @commits ||= begin
            @github.repos.commits.list(user: @user,
                                      repo: @repo,
                                      since: @since_date,
                                      until: @until_date).map { |c|
              # The commits list endpoint doesn't include all commit data, e.g. stats.
              # So, we make N requests here, where N == number of commits returned,
              # and then we die a bit inside.
              commit(c.sha)
            }
          end
        end

        def commit(sha)
          @commit[sha] ||= @github.repos.commits.get(user: @user, repo: @repo, sha: sha)
        end

        def stats
          return @stats if @stats

          stats = {
            "total" => 0,
            "additions" => 0,
            "deletions" => 0,
          }

          commits.map do |commit|
            stats.keys.each do |key|
              stats[key] += commit.stats[key]
            end
          end

          @stats = stats
        end

        def changed_files
          return @changed_files if @changed_files

          files = []

          commits.map do |commit|
            files += commit.files.map { |file| file["filename"] }
          end

          @changed_files = files.sort.uniq
        end

        def changes
          {"stats" => stats, "files" => changed_files}
        end

        def additions_count
          changes["stats"]["additions"]
        end

        def deletions_count
          changes["stats"]["deletions"]
        end

        def compare_url
          "https://github.com/#{@user}/#{@repo}/compare/#{default_branch}@%7B#{@since_date}%7D...#{default_branch}@%7B#{@until_date}%7D" # rubocop:disable Metrics/LineLength
        end

        def default_branch
          @default_branch ||= @github.repos.get(user: @user,
            repo: @repo).default_branch
        end

        # rubocop:disable Metrics/AbcSize
        def to_html(start_text: nil)
          start_text ||= "From #{pretty_date(@since_date)} through #{pretty_date(@until_date)}"

          HowIs.apply_template("contributions_partial", {
            start_text: start_text,
            user: @user,
            repo: @repo,
            compare_url: compare_url,
            additions_count_str: (additions_count == 1) ? "was" : "were",
            authors: pluralize("author", contributors.length),
            new_commits: pluralize("new commit", commits.length),
            additions: pluralize("addition", additions_count),
            deletions: pluralize("deletion", deletions_count),
            changed_files: pluralize("file", changed_files.length),
          }).strip
        end
        # rubocop:enable Metrics/AbcSize
      end
    end
  end
end
