# frozen_string_literal: true

require "how_is/report"
require "how_is/warning_helpers"

module HowIs
  ##
  # A class representing a collection of Reports.
  class ReportCollection
    include WarningHelpers

    def initialize(config, date)
      @report = Report.new(config, date)
      @repository = config["repository"]
      @config = config
      @date = date
    end

    def metadata
      end_date = DateTime.strptime(@date, "%Y-%m-%d")
      friendly_end_date = end_date.strftime("%B %d, %y")

      {
        repository: @repository,
        date: end_date,
        friendly_date: friendly_end_date,
      }
    end
    private :metadata

    def to_h
      @config["reports"].map { |format, report_config|
        # Sometimes report_data has unused keys, which generates a warning, but
        # we're okay with it, so we wrap it with silence_warnings {}.
        filename = silence_warnings { report_config["filename"] % metadata }

        file = File.join(report_config["directory"], filename)

        # Export +report+ to the specified +format+ with the specified
        # +frontmatter+.
        export = @report.send("to_#{format}", report_config["frontmatter"])

        [file, export]
      }.to_h
    end
  end
end
