# frozen_string_literal: true

require "spec_helper"
require "how_is/cli"

CLI_EXAMPLE_REPORT_FILE = File.expand_path("../data/how_is/cli_spec/example_report.json", __dir__)

describe HowIs::CLI do
  subject { HowIs::CLI }

  context "#parse" do
    it "converts flags to a Array" do
      opts, options = subject.parse(%w[--version])

      expect(opts).to_not be(nil)
      expect(options).to be_a(Hash)
      expect(options[:version]).to eq(true)
    end

    it "raises an OptionParser::MissingArgument if no date is specified" do
      expect {
        subject.parse(%w[])
      }.to raise_error(OptionParser::MissingArgument, /--date/)
    end

    it "raises an OptionParser::MissingArgument if a repository is required but not specified" do
      expect {
        subject.parse(%w[--date 2018-01-01])
      }.to raise_error(OptionParser::MissingArgument, /--repository/)
    end

    it "returns an error if you specify an invalid format" do
      expect {
        subject.parse(%w[--output invalid.format --date 2018-01-01 --resitory how-is/example-repository])
      }.to raise_error(OptionParser::InvalidArgument, /--output/)
    end
  end
end
