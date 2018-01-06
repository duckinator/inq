# frozen_string_literal: true

require "how_is/sources/github/contributions"

describe HowIs::Sources::Github::Contributions do
  let(:contributions) {
    described_class.new("how-is/example-repository", "2017-08-01", "2017-09-01")
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
          commit["tree"]["sha"]
        }
        expect(commit_shas).to eq(%w[
          6911e0637822f44b83f04f47821adab56fdbc0b9
          8286e548e330cfe01efcf7189f4df1fa53e777a7
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

  context "#changed_files" do
    it "returns a hash containing all of the changed files" do
      VCR.use_cassette("how_is_contributions_changed_files") do
        expect(contributions.changed_files).to eq(["README.md"])
      end
    end
  end

  context "#additions_count" do
    it "returns the number of additions during the specified period" do
      VCR.use_cassette("how_is_contributions_additions_count") do
        expect(contributions.additions_count).to eq(2)
      end
    end
  end

  context "#deletions_count" do
    it "returns the number of deletions during the specified period" do
      VCR.use_cassette("how_is_contributions_deletions_count") do
        expect(contributions.deletions_count).to eq(1)
      end
    end
  end

  context "#compare_url" do
    it "returns the GitHub URL that shows information about the specified period" do
      VCR.use_cassette("how_is_contributions_compare_url") do
        # rubocop:disable Metrics/LineLength
        expect(contributions.compare_url).to eq("https://github.com/how-is/example-repository/compare/master@%7B2017-08-01%7D...master@%7B2017-09-01%7D")
        # rubocop:enable Metrics/LineLength
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

  context "#summary" do
    it "generate a summary of the changes" do
      VCR.use_cassette("how_is_contributions_summary") do
        # rubocop:disable Metrics/LineLength
        summary = 'From Aug 01, 2017 through Sep 01, 2017, how-is/example-repository gained <a href="https://github.com/how-is/example-repository/compare/master@%7B2017-08-01%7D...master@%7B2017-09-01%7D">2 new commits</a>, contributed by 2 authors. There were 2 additions and 1 deletion across 1 file.'
        # rubocop:enable Metrics/LineLength
        p contributions.summary
        p summary
        expect(contributions.summary).to eq summary
      end
    end

    it "lets you change the beginning text" do
      VCR.use_cassette("how_is_contributions_summary_2") do
        expect(contributions.summary(start_text: "woof")).to start_with(
          "woof, how-is/example-repository"
        )
      end
    end
  end

  context "#pretty_date" do
    it "formats the date correctly" do
      date = "2017-01-02"
      expect(contributions.send(:pretty_date, date)).to eq("Jan 02, 2017")
    end
  end
end
