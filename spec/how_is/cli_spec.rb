# frozen_string_literal: true

require "spec_helper"
require "how_is/cli"

CLI_EXAMPLE_REPORT_FILE = File.expand_path("../data/how_is/cli_spec/example_report.json", __dir__)

describe HowIs::CLI do
  subject { HowIs::CLI }

  context "#parse" do
    it "converts flags to a Hash" do
      actual = subject.parse(%w[--version])

      expect(actual[:options][:version]).to eq(true)
    end

    it "raises HowIs::CLI::ArgumentError if a repository is required but not specified" do
      expect {
        subject.parse(%w[])
      }.to raise_error(HowIs::CLI::ArgumentError)
    end

    it "raises HowIs::CLI::ArgumentError if you specify an invalid format" do
      expect {
        subject.parse(%w[--output has_an.invalidformat how-is/example-repository])
      }.to raise_error(HowIs::CLI::ArgumentError, /has_an.invalidformat/)
    end
  end
end
