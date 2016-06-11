module HowIs
  class UnsupportedExportFormat < StandardError
    def initialize(format)
      super("Unsupported export format: #{format}")
    end
  end

  ##
  # Represents a completed report.
  class BaseReport < Struct.new(:analysis, :file)
    def to_h
      analysis.to_h
    end
    alias :to_hash :to_h

    def to_json
      to_h.to_json
    end

    private
      def issue_or_pr_summary(type, type_label)
        oldest_date_format = "%b %e, %Y"
        a = analysis

        number_of_type = a.send("number_of_#{type}s")

        "There are #{number_of_type} #{type_label}s open. " +
        "The average #{type_label} age is #{a.send("average_#{type}_age")}, and the " +
        "oldest was opened on #{a.send("oldest_#{type}_date").strftime(oldest_date_format)}"
      end
  end

  class Report
    require 'how_is/report/pdf'
    require 'how_is/report/json'

    def self.export!(analysis, file)
      extension = file.split('.').last
      class_name = "#{extension.capitalize}Report"

      raise UnsupportedExportFormat, extension unless HowIs.const_defined?(class_name)

      report = HowIs.const_get(class_name).new(analysis, file)

      report.export! {
        title "How is #{analysis.repository}?"

        header "Pull Requests"
        text issue_or_pr_summary "pull", "pull request"

        header "Issues"
        text issue_or_pr_summary "issue", "issue"

        header "Issues Per Label"
        issues_per_label = analysis.issues_with_label.to_a.sort_by { |(k, v)| v.to_i }.reverse
        horizontal_bar_graph issues_per_label
      }

      report
    end
  end
end
