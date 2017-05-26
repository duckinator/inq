# frozen_string_literal: true

require 'how_is/report/base_report'

class HowIs
  ##
  # A JSON report.
  class JsonReport < BaseReport
    # A JSON report is simply a JSON dump of the corresponding
    # HowIs::Analysis instance.

    ##
    # The format of the report.
    #
    # @return [Symbol] The name of the format.
    def format
      :json
    end

    ##
    # Generates a report.
    def export
      to_json
    end

    ##
    # Generates a report and writes it to a file.
    def export_file(file)
      File.open(file, 'w') do |f|
        f.write export
      end
    end
  end
end
