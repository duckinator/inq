require 'contracts'
require 'csv'

module HowBad
  ##
  # Represents a completed report.
  class Report < Struct.new(:analysis, :file)
    def initialize(analysis, file)
      super(analysis, file)
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
