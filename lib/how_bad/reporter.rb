require 'contracts'
require 'simple_xslx'

module HowBad
  ##
  # Represents a completed report.
  class Report < Struct.new(:analysis, :file)
    def initialize(analysis, file)
      super(analysis, file)
    end

    def to_hash
      analysis.to_hash
    end

    def export!(filename=file)
      serializer =
        SimpleXslx::Serializer.new(filename) do |doc|
          hash = to_hash

          doc.add_sheet("Report")
          sheet.add_row(hash.keys)
          sheet.add_row(hash.values)
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
