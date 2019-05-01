# frozen_string_literal: true

require "inq/sources/ci/travis"
require "inq/sources/ci/appveyor"

describe Inq::Sources::CI::Travis do
  subject do
    cache = cache("2018-03-01", "2017-04-15")
    described_class.new(config("duckinator/inq"), "2018-03-01", "2017-04-15", cache)
  end

  describe "#builds" do
    around(:example) do |example|
      load_test_env { example.run }

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
