require 'contracts'
require 'csv'
require 'prawn'

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
        font("Courier")

        span(450, position: :center) do
          pad(10) { text "How is #{a.repository}?" }
          pad(10) {
            text "Open issues:        #{a.number_of_issues}"
            text "Open pull requests: #{a.number_of_pulls}"
          }
          pad(10) {
            text "TODO: Issues per label."
            text "TODO: PRs per label."
          }
          pad(10) {
            text "Average issue age: #{a.average_issue_age}"
            text "Average PR age:    #{a.average_pull_age}"
          }
          pad(10) {
            text "Oldest issue opened on: #{a.oldest_issue_date.strftime(oldest_date_format)}"
            text "Oldest PR opened on:    #{a.oldest_pull_date.strftime(oldest_date_format)}"
          }
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
