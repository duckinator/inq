require 'contracts'
require 'prawn'
require 'prawn/table'
require 'how_is/chart'

module HowIs
  class Reporter
    require 'how_is/report'
    include Contracts::Core

    ##
    # Given an Analysis, generate a Report
    #
    # Returns a class that inherits from Report.
    Contract Analysis, String => C::Any
    def call(analysis, report_file)
      Report.export!(analysis, report_file)
    end
  end
end
