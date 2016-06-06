require 'how_is/version'
require 'contracts'

C = Contracts

module HowIs
  include Contracts::Core

  require 'how_is/fetcher'
  require 'how_is/analyzer'
  require 'how_is/reporter'

  Contract C::KeywordArgs[repository: String, report_file: String] => Report
  def self.generate_report(repository:, report_file:, from_file: nil,
        fetcher:  Fetcher.new,
        analyzer: Analyzer.new,
        reporter: Reporter.new)
    raise NotImplementedError, "--from not implemented yet" if from_file

    raw_data = fetcher.call(repository)
    analysis = analyzer.call(raw_data)

    reporter.call(analysis, report_file)
  end
end
