# frozen_string_literal: true

require "how_is/contributions"

describe HowIs::Contributions do
  let(:github) { HowIs::Fetcher.default_github_instance }
  let(:user) { "how-is" }
  let(:repo) { "example-repository" }
  let(:start_date) { "2017-08-01" }

  let(:contributions) {
    described_class.new(github: github,
                        user: user,
                        repo: repo,
                        start_date: start_date)
  }

  context "#contributors" do
    it "lists the contributors hash keyed by email" do
      VCR.use_cassette("how_is_contributions_all_contributors") do
        expect(contributions.contributors.keys).to(
          match_array(["me@duckie.co", "fake@duckinator.net"])
        )
      end
    end
  end

  # NOTE: This implicitly tests #contributors. (Because it doesn't work right
  #       if #contributors doesn't.)
  context "#new_contributors" do
    it "lists only the new contributors during the month starting with the specified date" do
      VCR.use_cassette("how_is_contributions_new_contributors") do
        expect(contributions.new_contributors.keys).to(
          match_array(["fake@duckinator.net"])
        )
      end
    end
  end

  # NOTE: This implicitly tests #commit, since it includes #commit's output.
  context "#commits" do
    it "lists all commits during the month starting with the specified date" do
      VCR.use_cassette("how_is_contributions_commits") do
        commit_shas = contributions.commits.map(&:commit).map { |commit|
                        commit['tree']['sha']
                      }
        expect(commit_shas).to eq([
          "6911e0637822f44b83f04f47821adab56fdbc0b9",
          "8286e548e330cfe01efcf7189f4df1fa53e777a7",
        ])
      end
    end
  end

  context "#changes" do
    # TODO: Phrase this better.
    it "returns a hash containing all of the changed stats and files" do
      VCR.use_cassette("how_is_contributions_changes") do
        results_hash = contributions.changes
        stats = results_hash["stats"]
        files = results_hash["files"]

        expect(stats).to eq({
          "total"     => 3,
          "additions" => 2,
          "deletions" => 1,
        })
        expect(files).to eq(["README.md"])
      end
    end
  end

  context "#default_branch" do
    it "fetches default branch" do
      VCR.use_cassette("how_is_contributions_default_branch") do
        expect(contributions.default_branch).to eq "master"
      end
    end
  end
end
