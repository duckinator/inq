# frozen_string_literal: true

require "how_is/version"
require "how_is/report"
require "github_api"

module HowIs
  DEFAULT_REPORT_FILE = "report.html"

  def self.new(repository, date)
    Report.new(repository, date)
  end

  def self.github
    @@github ||=
      Github.new(auto_pagination: true) do |config|
        config.basic_auth = ENV["HOWIS_BASIC_AUTH"] if ENV["HOWIS_BASIC_AUTH"]
      end
  end

  ##
  # Given a JSON report, create a new HowIs object (for generating other
  # reports).
  #
  # @param json [String] A JSON report object.
  # @return [HowIs] A HowIs object that can be used for generating other
  #   reports, treating the JSON report as a cache.
  def self.from_json(json)
    from_hash(JSON.parse(json))
  end

  ##
  # Given report data as a hash, create a new HowIs object (for generating
  # other reports).
  #
  # @param data [Hash] A hash containing report data.
  # @return [HowIs] A HowIs object that can be used for generating other
  #   reports, treating the provided report data as a cache.
  def self.from_hash(data)
    analysis = HowIs::Analysis.from_hash(data)

    new(analysis.repository, analysis)
  end

  ##
  # Generates a series of report files based on a config Hash.
  #
  # @param config [Hash] A Hash specifying the formats, locations, etc
  #   of the reports to generate.
  # @param date [String] A string containing the date (YYYY-MM-DD) that the
  #   report ends on. E.g., for Jan 1-Feb 1 2017, you'd pass 2017-02-01.
  def self.from_config(config, date)
    report = Report.new(config["repository"], date)
    report_data = prepare_report_metadata(config["repository"], date)

    generated_reports =
      config["reports"].map { |format, report_config|
        # Sometimes report_data has unused keys, which generates a warning, but
        # we're okay with it, so we wrap it with silence_warnings {}.
        filename = silence_warnings { report_config["filename"] % report_data }
        file = File.join(report_config["directory"], filename)

        report_export = report.send("to_#{format}", report_config["frontmatter"])

        [file, report_export]
      }

    generated_reports.to_h
  end

  ##
  # Returns a list of possible export formats.
  #
  # @return [Array<String>] An array of the types of reports you can generate.
  def self.supported_formats
    ["html", "json"]
  end

  def self.template(filename)
    dir  = File.expand_path("./how_is/templates/", __dir__)
    path = File.join(dir, filename)

    open(path).read
  end

  ##
  # Returns whether or not the specified +file+ can be exported to.
  #
  # @param file [String] A filename.
  # @return [Boolean] +true+ if HowIs can export to the file, +false+
  #   if it can't.
  def self.can_export_to?(file)
    # TODO: Check if the file is writable?
    supported_formats.include?(file.split(".").last)
  end

  def self.silence_warnings(&block)
    with_warnings(nil, &block)
  end
  private_class_method :silence_warnings

  def self.with_warnings(flag, &_block)
    old_verbose = $VERBOSE
    $VERBOSE = flag
    yield
  ensure
    $VERBOSE = old_verbose
  end
  private_class_method :with_warnings

  def self.prepare_report_metadata(repository, date)
    end_date = DateTime.strptime(date, "%Y-%m-%d")
    friendly_end_date = end_date.strftime("%B %d, %y")

    {
      repository: repository,
      date: end_date,
      friendly_date: friendly_end_date,
    }
  end
  private_class_method :prepare_report_metadata
end
