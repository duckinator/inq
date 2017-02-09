require 'how_is/version'
require 'contracts'
require 'cacert'

Cacert.set_in_env

C = Contracts

class HowIs
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
  def initialize(repository, **kw_args)
    @analysis = HowIs.generate_analysis(repository: repository, **kw_args)
  end

  def to_html
    Report.export(@analysis, :html)
  end

  def to_json
    Report.export(@analysis, :json)
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

  # Generates YAML frontmatter, as is used in Jekyll and other blog engines.
  #
  # E.g.,
  #     generate_frontmatter({'foo' => "bar %{baz}"}, {'baz' => "asdf"})
  # =>  "---\nfoo: bar asdf\n"
  Contract C::HashOf[C::Or[String, Symbol] => String],
           C::HashOf[C::Or[String, Symbol] => C::Any] => String
  def self.generate_frontmatter(frontmatter, report_data)
    frontmatter = convert_keys(frontmatter, :to_s)
    report_data = convert_keys(report_data, :to_sym)

    frontmatter = frontmatter.map { |k, v|
      v = v % report_data

      [k, v]
    }.to_h

    YAML.dump(frontmatter)
  end

  ##
  # Generates a series of report files based on a YAML config file.
  def self.from_config_file(config_file, **kwargs)
    from_config(YAML.load_file(config_file), **kwargs)
  end

  ##
  # Generates a series of report files based on a config Hash.
  def self.from_config(config,
        github: nil,
        report_class: nil)
    report_class ||= HowIs::Report

    date = Date.strptime(Time.now.to_i.to_s, '%s')
    date_string = date.strftime('%Y-%m-%d')
    friendly_date = date.strftime('%B %d, %y')

    analysis = HowIs.generate_analysis(repository: config['repository'], github: github)

    report_data = {
      repository: config['repository'],
      date: date,
      friendly_date: friendly_date,
    }

    generated_reports = {}

    config['reports'].map do |format, report_config|
      filename = report_config['filename'] % report_data
      file = File.join(report_config['directory'], filename)

      report = report_class.export(analysis, format)

      result = build_report(report_config['frontmatter'], report_data, report)

      generated_reports[file] = result

      result
    end

    generated_reports
  end

  # Combine the frontmatter, report data, and raw report into a report with
  # frontmatter.
  def self.build_report(frontmatter, report_data, report)
    str = StringIO.new

    if frontmatter
      str.puts generate_frontmatter(frontmatter, report_data)
      str.puts "---"
      str.puts
    end

    str.puts report

    str.string
  end

private
  # convert_keys({'foo' => 'bar'}, :to_sym)
  # => {:foo => 'bar'}
  def self.convert_keys(data, method_name)
    data.map {|k, v| [k.send(method_name), v]}.to_h
  end

end
