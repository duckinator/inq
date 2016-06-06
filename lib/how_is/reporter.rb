require 'contracts'
require 'csv'
require 'prawn'
require 'prawn/table'

module HowIs
  class UnsupportedExportFormat < StandardError
    def initialize(format)
      super("Unsupported export format: #{format}")
    end
  end

  ##
  # Represents a completed report.
  class Report < Struct.new(:analysis, :file)
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

    def export_json!(filename=file)
      File.open(filename, 'rw') do |f|
        f.write to_h.to_json
      end
    end

    def export_pdf!(filename=file)
      oldest_date_format = "%b %e, %Y"
      a = analysis

      Prawn::Document.generate(filename) do
        font("Helvetica")

        span(450, position: :center) do
          pad(10) { text "How is #{a.repository}?", size: 25 }
          pad(5)  { text "Issues" }
          text issue_or_pr_summary(a, "issue", "issue")
          pad(5)  { text "Pull Requests" }
          text issue_or_pr_summary(a, "pull", "pull request")

          pad(10) { text "Issues per label" }
          table a.issues_with_label.to_a.sort_by { |(k, v)| v.to_i }.reverse

          # TODO: GitHub's API doesn't include labels for PRs but does for issues?!
          pad(10) { text "Pull Requests per label" }
          text "TODO."
          #table a.pulls_with_label.to_a
        end
      end
    end

    def export!(filename=file)
      extension = filename.split('.').last
      method_name = "export_#{extension}!"

      if respond_to?(method_name)
        send(method_name, filename)
      else
        raise UnsupportedExportFormat, filename.split('.').last
      end
    end

  private
    def issue_or_pr_summary(analysis, type, type_label)
      a = analysis

      "#{a.repository} has #{a.send("number_of_#{type}s")} #{type_label}s open. " +
      "The average #{type_label} age is #{a.send("average_#{type}_age")}, and the " +
      "oldest #{type_label} was opened on #{a.send("oldest_#{type}_date").strftime(oldest_date_format)}"
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
