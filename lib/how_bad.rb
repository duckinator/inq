require "how_bad/version"

module HowBad
  require "how_bad/fetcher"
  require "how_bad/analyzer"
  require "how_bad/reporter"

  def self.generate_report(**options)
    raw_data = Fetcher.new.call(**options)
    analysis = Analyzer.new.call(raw_data, **options)

    Reporter.new.call(analysis, **options)
  end
end
