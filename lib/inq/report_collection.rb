# frozen_string_literal: true

require "inq/report"
require "okay/warning_helpers"

module Inq
  ##
  # A class representing a collection of Reports.
  class ReportCollection
    include Okay::WarningHelpers

    def initialize(config, start_date, end_date=nil)
      @config = config

      # If the config is in the old format, convert it to the new one.
      unless @config["repositories"]
        @config["repositories"] = [{
          "repository" => @config.delete("repository"),
          "reports" => @config.delete("reports"),
        }]
      end

      @start_date = start_date
      @end_date = end_date
      @reports = config["repositories"].map(&method(:fetch_report)).to_h
    end

    # Generates the metadata for the collection of Reports.
    def metadata(repository)
      end_date = DateTime.strptime(@end_date || @start_date, "%Y-%m-%d")
      friendly_end_date = end_date.strftime("%B %d, %y")

      {
        sanitized_repository: repository.tr("/", "-"),
        repository: repository,
        date: end_date,
        friendly_date: friendly_end_date,
      }
    end
    private :metadata

    def config_for(repo)
      defaults = @config.fetch("default_reports", {})
      config = @config.dup
      repos = config.delete("repositories")

      # Find the _last_ one that matches, to allow overriding.
      repo_config = repos.reverse.find { |conf| conf["repository"] == repo }

      # Use values from default_reports, unless overridden.
      config["repository"] = repo
      config["reports"] = defaults.merge(repo_config.fetch("reports", {}))
      config
    end
    private :config_for

    def fetch_report(repo_config)
      repo = repo_config["repository"]
      report = Report.new(config_for(repo), @start_date, @end_date)
      [repo, report]
    end
    private :fetch_report

    # Converts a ReportCollection to a Hash.
    #
    # Also good for giving programmers nightmares, I suspect.
    def to_h
      results = {}
      defaults = @config["default_reports"] || {}

      @config["repositories"].map { |repo_config|
        repo = repo_config["repository"]
        config = config_for(repo)

        config["reports"].map { |format, report_config|
          # Sometimes report_data has unused keys, which generates a warning, but
          # we're okay with it, so we wrap it with silence_warnings {}.
          filename = silence_warnings {
            tmp_filename = report_config["filename"] || defaults[format]["filename"]
            tmp_filename % metadata(repo)
          }

          directory = report_config["directory"] || defaults[format]["directory"]
          file = File.join(directory, filename)

          # Export +report+ to the specified +format+ with the specified
          # +frontmatter+.
          frontmatter = report_config["frontmatter"] || {}
          if defaults.has_key?(format) && defaults[format].has_key?("frontmatter")
            frontmatter = defaults[format]["frontmatter"].merge(frontmatter)
          end
          frontmatter = nil if frontmatter == {}

          export = @reports[repo].send("to_#{format}", frontmatter)

          results[file] = export
        }
      }
      results
    end

    # Save all of the reports to the corresponding files.
    #
    # @return [Array<String>] An array of file paths.
    def save_all
      reports = to_h
      reports.each do |file, report|
        File.write(file, report)
      end

      reports.keys
    end
  end
end
