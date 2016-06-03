require 'contracts'
require 'csv'

module HowBad
  class UnsupportedExportFormat < StandardError
    def initialize(format)
      super("Unsupported export format: #{format}")
    end
  end

  ##
  # Represents a completed report.
  class Report < Struct.new(:analysis, :file)
    def initialize(analysis, file)
      super(analysis, file)
    end

    def to_h
      analysis.to_h
    end
    alias :to_hash :to_h

    def export_csv!(filename=file)
      hash = to_h

      CSV.open(filename, "wb") do |csv|
        csv << hash.keys
        csv << hash.values
      end
    end

    def export_pdf!(filename=file)
      raise NotImplementedError
    end

    def export!(filename=file)
      extension = filename.split('.').last

      if extension == 'csv'
        export_csv!(filename)
      elsif extension == 'pdf'
        export_pdf!(filename)
      else
        raise UnsupportedExportFormat, filename.split('.').last
      end
    end
  end

  class Reporter
    include Contracts::Core

    ##
    # Given an Analysis, generate a Report
    Contract Analysis, String => Report
    def call(analysis, report_file)
      Report.new(analysis, report_file)
    end
  end
end
