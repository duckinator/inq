# frozen_string_literal: true

require "how_is/version"
require "how_is/config"
require "how_is/report"
require "how_is/report_collection"

##
# Top-level module for creating a report.
module HowIs
  def self.default_config(repository)
    {
      "repository" => repository,
      "reports" => {
        "html" => {
          "directory" => ".",
          "frontmatter" => {},
          "filename" => "report.html",
        },
      },
    }
  end

  def self.new(repository, date)
    config =
      Config
        .load_defaults
        .load(default_config(repository))
    Report.new(config, date)
  end

  ##
  # Generates a series of report files based on a config Hash.
  #
  # @param config [ReportCollection] All the information needed to generate
  #   the reports.
  # @param date [String] A string containing the date (YYYY-MM-DD) that the
  #   report ends on. E.g., for Jan 1-Feb 1 2017, you'd pass 2017-02-01.
  def self.from_config(config, date)
    raise "Expected config to be Hash, got #{config.class}" unless \
      config.is_a?(Hash)

    ReportCollection.new(config, date)
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
end
