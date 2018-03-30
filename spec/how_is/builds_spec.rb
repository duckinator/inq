# frozen_string_literal: true

require "how_is/sources/ci/travis"
require "how_is/sources/ci/appveyor"

describe HowIs::Sources::CI::Travis do
  subject do
    described_class.new("how-is/how_is", "2017-07-06", "2017-08-06")
  end

  describe "#builds" do
    it "returns a Hash" do
      VCR.use_cassette("how-is-how-is-travis-api-repos-builds") do
        expect(subject.builds).to be_a(Hash)
      end
    end
  end
end
