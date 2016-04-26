require "how_bad/version"
require "contracts"

C = Contracts

module HowBad
  include Contracts::Core

  require "how_bad/fetcher"
  require "how_bad/analyzer"
  require "how_bad/reporter"

  Contract C::KeywordArgs[repository: String, report_file: String] => C::Any
  def self.generate_report(repository:, report_file:,
        fetcher:  Fetcher.new,
        analyzer: Analyzer.new,
        reporter: Reporter.new)
    raw_data = fetcher.call(repository)
    analysis = analyzer.call(**raw_data)

    reporter.call(analysis, report_file)
  end
end
