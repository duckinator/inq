require 'how_is/version'
require 'contracts'
require 'cacert'

Cacert.set_in_env

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

  def self.generate_report(format:, **kw_args)
    analysis = self.generate_analysis(**kw_args)

    Report.export(analysis, format)
  end
private


Contract C::KeywordArgs[repository: String,
                        from_file: C::Optional[C::Or[String, nil]],
                        fetcher: C::Optional[Class],
                        analyzer: C::Optional[Class],
                        github: C::Optional[C::Any]] => C::Any
  def self.generate_analysis(repository:,
        from_file: nil,
        fetcher: Fetcher.new,
        analyzer: Analyzer.new,
        github: nil)
    if from_file
      analysis = analyzer.from_file(from_file)
    else
      raw_data = fetcher.call(repository, github)
      analysis = analyzer.call(raw_data)
    end

    analysis
  end
end
