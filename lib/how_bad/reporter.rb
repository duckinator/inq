require 'contracts'
require 'csv'
require 'prawn'
require 'prawn/table'

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
      a = analysis
      oldest_date_format = "%b %e, %Y"

      Prawn::Document.generate(filename) do
        font("Helvetica")

        span(450, position: :center) do
          pad(10) { text "How is #{a.repository}?", size: 25 }
          table([
            ["Open issues:",        a.number_of_issues],
            ["Open pull requests:", a.number_of_pulls],
            ["Issues per label:", "TODO"],
            ["PRs per label:", "TODO"],
            ["Average issue age:", a.average_issue_age],
            ["Average PR age:",    a.average_pull_age],
            ["Oldest issue opened on:", a.oldest_issue_date.strftime(oldest_date_format)],
            ["Oldest PR opened on:",    a.oldest_pull_date.strftime(oldest_date_format)],
          ],
          cell_style: { border_width: 0 })
        end
      end
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
