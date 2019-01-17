require "how_is/report"
require "how_is/warning_helpers"

module HowIs
  class ReportCollection
    include WarningHelpers

    def initialize(config, date)
      @report = Report.new(config, date)
      @repository = config["repository"]
      @config = config
      @date = date
    end

    def expand_filename(filename, report_data)
      # Sometimes report_data has unused keys, which generates a warning, but
      # we're okay with it, so we wrap it with silence_warnings {}.
      silence_warnings { filename % report_data }
    end
    private :expand_filename

    def prepare_report_metadata(repository, date)
      end_date = DateTime.strptime(date, "%Y-%m-%d")
      friendly_end_date = end_date.strftime("%B %d, %y")

      {
        repository: repository,
        date: end_date,
        friendly_date: friendly_end_date,
      }
    end
    private :prepare_report_metadata

    # Export +report+ to the specified +format+,
    # with the specified +frontmatter+.
    def report_export(report, format, frontmatter)
      report.send("to_#{format}", frontmatter)
    end
    private :report_export

    def to_h
      metadata = prepare_report_metadata(@config["repository"], @date)

      @config["reports"].map { |format, report_config|
        filename = expand_filename(report_config["filename"], metadata)
        file = File.join(report_config["directory"], filename)
        export = report_export(@report, format, report_config["frontmatter"])

        [file, export]
      }.to_h
    end
  end
end
