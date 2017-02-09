require 'spec_helper'
require 'how_is/cli'

describe HowIs::CLI::Parser do
  subject { HowIs::CLI::Parser.new }

  context '#parse' do
    it 'converts flags to a Hash' do
      actual = subject.call(%w[--version])

      expect(actual[:options][:version]).to eq(true)
    end

    it 'raises NoRepositoryError if a repository is required but not specified' do
      expect {
        subject.call(%w[])
      }.to raise_error(HowIs::CLI::NoRepositoryError)
    end

    it 'raises InvalidInputFileError if a specified JSON file doesn\'t exist' do
      expect {
        subject.call(%w[--from nonexistent.json])
      }.to raise_error(HowIs::CLI::InvalidInputFileError)
    end

    it 'raises InvalidOutputFileError if you specify an invalid format' do
      expect {
        subject.call(%w[--report has_an.invalidformat how-is/example-repository])
      }.to raise_error(HowIs::CLI::InvalidOutputFileError)
    end
  end

end
