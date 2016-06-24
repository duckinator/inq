require 'how_is/version'
require 'contracts'

C = Contracts

module HowIs
  include Contracts::Core

  require 'how_is/fetcher'
  require 'how_is/analyzer'
  require 'how_is/report'

  def self.generate_report_file(report_file:, **kw_args)
    analysis = self.generate_analysis(**kw_args)

    Report.export!(analysis, report_file)
  end

  def self.generate_report(**kw_args)
    analysis = self.generate_analysis(**kw_args)

    Report.export(analysis)
  end
private


Contract C::KeywordArgs[repository: String,
                        from_file: C::Optional[C::Or[String, nil]],
                        fetcher: C::Optional[Class],
                        analyzer: C::Optional[Class]] => C::Any
  def self.generate_analysis(repository:,
        from_file: nil,
        fetcher: Fetcher.new,
        analysis: Analyzer.new)
    if from_file
      analysis = analyzer.from_file(from_file)
    else
      raw_data = fetcher.call(repository)
      analysis = analyzer.call(raw_data)
    end

    analysis
  end
end
