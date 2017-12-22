# frozen_string_literal: true

require "how_is/sources/travis"

describe HowIs::Sources::Travis do
  subject do
    described_class.new("how-is/how_is", "2017-08-06")
  end

  describe "#builds" do
    it "returns a Hash" do
      VCR.use_cassette("how-is-how-is-travis-api-repos-builds") do
        expect(subject.builds).to be_a(Hash)
      end
    end
  end
end
