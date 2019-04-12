# frozen_string_literal: true

module HowIs
  # The file name used for a report if one isn't specified.
  DEFAULT_REPORT_FILE = "report.html"

  # Used by things making HTTP requests.
  USER_AGENT = "how_is/#{HowIs::VERSION} (https://github.com/how-is/how_is/)"
end
