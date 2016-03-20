require "how_bad/version"

module HowBad
  require "how_bad/fetcher"
  require "how_bad/analyzer"
  require "how_bad/reporter"

  def self.generate_report(repository:, report_file:)
    raw_data = Fetcher.new.call(repository)
    analysis = Analyzer.new.call(**raw_data)

    Reporter.new.call(analysis, report_file)
  end
end
