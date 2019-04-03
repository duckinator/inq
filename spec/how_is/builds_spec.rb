# frozen_string_literal: true

require "how_is/sources/ci/travis"
require "how_is/sources/ci/appveyor"

describe HowIs::Sources::CI::Travis do
  subject do
    config =
      HowIs::Config.new
        .load_defaults
        .load({"repository" => "how-is/how_is"})
    described_class.new(config, "2018-03-01", "2017-04-15")
  end

  describe "#builds" do
    around(:example) do |example|
      token = ENV["HOWIS_GITHUB_TOKEN"]
      username = ENV["HOWIS_GITHUB_USERNAME"]
      begin
        ENV["HOWIS_GITHUB_TOKEN"] = "blah"
        ENV["HOWIS_GITHUB_USERNAME"] = "who"
        example.run
      ensure
        ENV["HOWIS_GITHUB_TOKEN"] = token
        ENV["HOWIS_GITHUB_USERNAME"] = username
      end
    end

    it "returns an Array" do
        VCR.use_cassette("how-is-how-is-travis-api-repos-builds") do
          expect(subject.builds).to be_a(Array)
        end
    end
  end
end
