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

  context "#new_contributors" do
    it "lists only the new contributors since the given date" do
      VCR.use_cassette("how_is_contributions_new_contributors") do
        expect(contributions.new_contributors.keys).to(
          match_array(["fake@duckinator.net"])
        )
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
