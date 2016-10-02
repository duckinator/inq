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

  DEFAULT_FORMAT = :html

  ##
  # Generate a report file.
  def self.generate_report_file(report:, **kw_args)
    analysis = self.generate_analysis(**kw_args)

    Report.export_file(analysis, report)
  end

  ##
  # Generates and returns a report as a String.
  def self.generate_report(format:, **kw_args)
    analysis = self.generate_analysis(**kw_args)

    Report.export(analysis, format)
  end

  ##
  # Returns a list of possible export formats.
  def self.supported_formats
    report_constants = HowIs.constants.grep(/.Report/) - [:BaseReport]
    report_constants.map {|x| x.to_s.split('Report').first.downcase }
  end

  ##
  # Returns whether or not the specified +file+ can be exported to.
  def self.can_export_to?(file)
    # TODO: Check if the file is writable?
    supported_formats.include?(file.split('.').last)
  end

  # Generate an analysis. Used internally for generate_report{,_file}.
  Contract C::KeywordArgs[repository: String,
                          from: C::Optional[C::Or[String, nil]],
                          fetcher: C::Optional[Class],
                          analyzer: C::Optional[Class],
                          github: C::Optional[C::Any]] => C::Any
  def self.generate_analysis(repository:,
        from: nil,
        fetcher: Fetcher.new,
        analyzer: Analyzer.new,
        github: nil)
    if from
      analysis = analyzer.from_file(from)
    else
      raw_data = fetcher.call(repository, github)
      analysis = analyzer.call(raw_data)
    end

    analysis
  end
end
