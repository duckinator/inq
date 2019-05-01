# frozen_string_literal: true

module Inq
  # The file name used for a report if one isn't specified.
  DEFAULT_REPORT_FILE = "report.html"

  # Used by things making HTTP requests.
  USER_AGENT = "inq/#{Inq::VERSION} (https://github.com/duckinator/inq)"
end
