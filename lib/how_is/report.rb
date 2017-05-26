require 'date'
require "pathname"

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

    ##
    # Saves given Report in given file.
    #
    # @param file [String,Pathname] Name of file to write to
    # @param report [Report] Report to store
    def self.save_report(file, report)
      File.open(file, 'w') do |f|
        f.write report
      end
    end

    ##
    # Returns the report format for given filename.
    #
    # @param file [String] Filename of a report
    #
    # @return [String] Report format inferred from file name
    def self.infer_format(file)
      Pathname(file).extname.delete('.')
    end

    ##
    # Exports given +report+ to the format suitable for given +file+.
    #
    # @param file [String,Pathname]
    # @param report [Report]
    #
    # @return [String] The rendered report
    def self.to_format_based_on(file, report)
      report_format = infer_format(file)

      report.public_send("to_#{report_format}")
    end

    # Given a format name (+format+), returns the corresponding <blah>Report
    # class.
    def self.get_report_class(format)
      class_name = "#{format.capitalize}Report"

      raise UnsupportedExportFormat, format unless HowIs.const_defined?(class_name)

      HowIs.const_get(class_name)
    end
    private_class_method :get_report_class
  end
end
