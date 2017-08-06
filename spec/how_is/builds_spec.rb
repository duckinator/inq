# frozen_string_literal: true

require "how_is/builds"

describe HowIs::Builds do
  let(:user) { "how-is" }
  let(:repo) { "how_is" }

  subject(:builds) do
    described_class.new(user: user, repo: repo)
  end

  describe "#summary" do
    it "returns a Hash" do
      VCR.use_cassette('how-is-how-is-travis-api-repos-builds') do
        expect(builds.summary).to be_a(Hash)
      end
    end
  end
end