# frozen_string_literal: true

require "how_is/version"
require "how_is/constants"
require "how_is/report"

##
# Top-level module for creating a report.
module HowIs
  def self.new(repository, date)
    Report.new(repository, date)
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

    config["reports"].map { |format, report_config|
      filename = expand_filename(report_config["filename"], report_data)
      file = File.join(report_config["directory"], filename)
      export = report_export(report, format, report_config["frontmatter"])

      [file, export]
    }.to_h
  end

  ##
  # Returns a list of possible export formats.
  #
  # @return [Array<String>] An array of the types of reports you can generate.
  def self.supported_formats
    ["html", "json"]
  end

  ##
  # Returns whether or not the specified +format+ is supported.
  #
  # @param format_name [String] The format in question.
  # @return [Boolean] +true+ if HowIs supports the format, +false+ otherwise.
  def self.supported_format?(format_name)
    supported_formats.include?(format_name)
  end

  def self.template(filename)
    dir  = File.expand_path("./how_is/templates/", __dir__)
    path = File.join(dir, filename)

    open(path).read
  end

  def self.apply_template(template_name, data)
    template_str = template(template_name + ".html_template")
    silence_warnings {
      Kernel.format(template_str, data)
    }
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

  def self.expand_filename(filename, report_data)
    # Sometimes report_data has unused keys, which generates a warning, but
    # we're okay with it, so we wrap it with silence_warnings {}.
    silence_warnings { filename % report_data }
  end
  private_class_method :expand_filename

  # Export +report+ to the specified +format+,
  # with the specified +frontmatter+.
  def self.report_export(report, format, frontmatter)
    report.send("to_#{format}", frontmatter)
  end
  private_class_method :report_export

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
