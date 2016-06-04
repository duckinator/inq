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
      oldest_date_format = "%b %e, %Y"
      a = analysis

      issue_or_pr_summary = lambda do |analysis, type, type_label|
        a = analysis

        span  "#{a.repository} has #{a.send("number_of_#{type}")} #{type_label}s open. " +
              "The average #{type_label} age is #{a.send("average_#{type}_age")}, and the " +
              "oldest #{type_label} was opened on #{a.send("oldest_#{type}_date").strftime(oldest_date_format)}"
      end

      Prawn::Document.generate(filename) do
        font("Helvetica")

        span(450, position: :center) do
          pad(10) { text "How is #{a.repository}?", size: 25 }
          pad(5)  { text "Issues" }
          span issue_or_pr_summary.call(a, "issue", "issue")
          pad(5)  { text "Pull Requests" }
          span issue_or_pr_summary.call(a, "pulls", "pull request")

          pad(10) { text "Issues per label" }
          table a.issues_with_label.to_a

          pad(10) { text "Pull Requests per label" }
          table a.pulls_with_label.to_a
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
