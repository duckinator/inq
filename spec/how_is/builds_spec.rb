# frozen_string_literal: true

require "how_is/sources/ci/travis"
require "how_is/sources/ci/appveyor"

describe HowIs::Sources::CI::Travis do
  subject do
    cache = cache("2018-03-01", "2017-04-15")
    described_class.new(config("how-is/how_is"), "2018-03-01", "2017-04-15", cache)
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

      # This will fail without VCR if the cache isn't working
      expect(subject.builds).to be_a(Array)
    end

    it "returns an Array" do
        VCR.use_cassette("how-is-how-is-travis-api-repos-builds") do
          expect(subject.builds).to be_a(Array)
        end
    end
  end
end
