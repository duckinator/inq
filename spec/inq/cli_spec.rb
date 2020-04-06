# frozen_string_literal: true

require "spec_helper"
require "inq/cli"

CLI_EXAMPLE_REPORT_FILE = File.expand_path("../data/how_is/cli_spec/example_report.json", __dir__)

describe Inq::CLI do
  subject { Inq::CLI }

  context "#parse" do
    it "takes an Array of args and returns a Inq::CLI object" do
      cli = subject.parse(["--version"])

      expect(cli.help_text).to be_a(String)
      expect(cli.options).to be_a(Hash)
      expect(cli.options[:version]).to eq(true)
    end

    it "raises an OptionParser::MissingArgument if no date is specified" do
      expect {
        subject.parse([])
      }.to raise_error(OptionParser::MissingArgument, /--date/)
    end


    it "raises an OptionParser::MissingArgument if start date is required but not specified" do
      expect {
        subject.parse(["--start-date"])
      }.to raise_error(OptionParser::MissingArgument, /--start-date/)
    end

    it "raises an OptionParser::MissingArgument if end date is required but not specified" do
      expect {
        subject.parse(["--end-date"])
      }.to raise_error(OptionParser::MissingArgument, /--end-date/)
    end

    it "raises an OptionParser::MissingArgument if a repository is required but not specified" do
      expect {
        subject.parse(["--date", "2018-01-01"])
      }.to raise_error(OptionParser::MissingArgument, /--repository/)
    end

    it "returns an error if you specify an invalid format" do
      expect {
        subject.parse([
          "--output", "invalid.format",
          "--date", "2018-01-01",
          "--repossitory", "how-is/example-repository"
        ])
      }.to raise_error(OptionParser::InvalidArgument, /--output/)
    end
  end
end
