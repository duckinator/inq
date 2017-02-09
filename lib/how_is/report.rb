require 'date'
require 'how_is/pulse'

class HowIs
  class UnsupportedExportFormat < StandardError
    def initialize(format)
      super("Unsupported export format: #{format}")
    end
  end

  class Report
    require 'how_is/report/json'
    require 'how_is/report/html'

    ##
    # Export a report to a file.
    def self.export_file(analysis, file)
      format = file.split('.').last
      report = get_report_class(format).new(analysis)

      report.export_file(file)
    end

    ##
    # Export a report to a String.
    def self.export(analysis, format = HowIs::DEFAULT_FORMAT)
      report = get_report_class(format).new(analysis)

      report.export
    end

  private
    # Given a format name (+format+), returns the corresponding <blah>Report
    # class.
    def self.get_report_class(format)
      class_name = "#{format.capitalize}Report"

      raise UnsupportedExportFormat, format unless HowIs.const_defined?(class_name)

      HowIs.const_get(class_name)
    end
  end
end
