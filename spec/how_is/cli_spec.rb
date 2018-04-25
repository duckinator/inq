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

    it "returns an error if no date is specified" do
      result = subject.parse(%w[])
      expect(result).to have_key(:error)

      error, data = result[:error]
      expect(error).to eq(:no_date)
      expect(data).to be_nil
    end

    it "returns an error if a repository is required but not specified" do
      result = subject.parse(%w[--date 2018-01-01])
      expect(result).to have_key(:error)

      error, data = result[:error]
      expect(error).to eq(:no_repo)
      expect(data).to be_nil
    end

    it "returns an error if you specify an invalid format" do
      result =
        subject.parse(%w[--output invalid.format --date 2018-01-01 how-is/example-repository])
      expect(result).to have_key(:error)

      error, data = result[:error]
      expect(error).to eq(:unsupported_format)
      expect(data).to eq("format")
    end
  end
end
