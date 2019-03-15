# frozen_string_literal: true

require "how_is/sources/ci/travis"
require "how_is/sources/ci/appveyor"

describe HowIs::Sources::CI::Travis do
  subject do
    config =
      HowIs::Config
        .load_defaults
        .load({"repository" => "how-is/how_is"})
    described_class.new(config, "2018-03-01", "2017-04-15")
  end

  describe "#builds" do
    it "returns an Array" do
      VCR.use_cassette("how-is-how-is-travis-api-repos-builds") do
        expect(subject.builds).to be_a(Array)
      end
    end
  end
end
