# frozen_string_literal: true

require "how_is/version"
require "how_is/report"
require "how_is/report_collection"

##
# Top-level module for creating a report.
module HowIs
  def self.new(repository, date)
    # TODO: Define a proper default config?
    Report.new({
      "repository" => repository,
      "reports" => {
        "html" => {
          "directory" => ".",
          "frontmatter" => {},
          "filename" => "report.html"
        }
      }
    }, date)
  end

  ##
  # Generates a series of report files based on a config Hash.
  #
  # @param config [Hash] A Hash specifying the formats, locations, etc
  #   of the reports to generate.
  # @param date [String] A string containing the date (YYYY-MM-DD) that the
  #   report ends on. E.g., for Jan 1-Feb 1 2017, you'd pass 2017-02-01.
  def self.from_config(config, date)
    ReportCollection.new(config, date).to_h
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
