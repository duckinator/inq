# frozen_string_literal: true

require "spec_helper"
require "json"

FETCHER_SPEC_DATA_DIR = File.expand_path("../data/how_is/fetcher_spec", __dir__)
FETCHER_SPEC_EXAMPLE_OUTPUT_FILE = File.join(FETCHER_SPEC_DATA_DIR, "fetcher_call.json")

describe HowIs::Fetcher do
  context "#call" do
    it "returns a hash containing issues and pull requests" do
      VCR.use_cassette("how_is_fetcher_call") do
        actual = subject.call("how-is/example-repository", "2017-09-01")
        actual_json = actual.to_hash.to_json.strip

        expected_json = File.read(FETCHER_SPEC_EXAMPLE_OUTPUT_FILE).strip

        expect(actual_json).to eq(expected_json)
      end
    end
  end
end
