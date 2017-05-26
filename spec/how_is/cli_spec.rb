# frozen_string_literal: true

require 'spec_helper'
require 'how_is/cli'

CLI_EXAMPLE_REPORT_FILE = File.expand_path('../data/how_is/cli_spec/example_report.json', __dir__)

describe HowIs::CLI do
  subject { HowIs::CLI }

  context '#parse' do
    it 'converts flags to a Hash' do
      actual = subject.parse(%w[--version])

      expect(actual[:options][:version]).to eq(true)
    end

    it 'raises NoRepositoryError if a repository is required but not specified' do
      expect {
        subject.parse(%w[])
      }.to raise_error(HowIs::CLI::NoRepositoryError)
    end

    it 'raises InvalidInputFileError if a specified JSON file doesn\'t exist' do
      expect {
        subject.parse(%w[--from nonexistent.json])
      }.to raise_error(HowIs::CLI::InvalidInputFileError)
    end

    it "doesn't raise an error if the JSON file exists and has a 'repository' key" do
      actual = nil

      expect {
        actual = subject.parse(%W[--from #{CLI_EXAMPLE_REPORT_FILE}])
      }.to_not raise_error

      expect(actual[:options][:from]).to eq(CLI_EXAMPLE_REPORT_FILE)
    end

    it 'raises InvalidOutputFileError if you specify an invalid format' do
      expect {
        subject.parse(%w[--report has_an.invalidformat how-is/example-repository])
      }.to raise_error(HowIs::CLI::InvalidOutputFileError, /has_an.invalidformat/)
    end
  end
end
