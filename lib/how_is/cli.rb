# frozen_string_literal: true

require "how_is"
require "optparse"

module HowIs
  module CLI
    REPO_REGEXP = /.+\/.+/
    DATE_REGEXP = /\d\d\d\d-\d\d-\d\d/

    # Parses +argv+ to generate an options Hash to control the behavior of
    # the library.
    def self.parse(argv)
      opts, options = parse_main(argv)

      # Options that are mutually-exclusive with everything else.
      options = {:help    => true} if options[:help]
      options = {:version => true} if options[:version]

      validate_options!(options)

      # Return an Array containing:
      #   +opts+: the original OptionParser object.
      #   +options+: the Hash of flags/values.
      [opts, options]
    end

    def self.parse_main(argv)
      options = {
        report: HowIs::DEFAULT_REPORT_FILE,
      }
      opts = nil

      opt_parser = OptionParser.new do |opts_|
        opts = opts_
        # General usage information.
        opts.banner = <<~EOF
          Usage: how_is --repository REPOSITORY --date REPORT_DATE [--output REPORT_FILE]
                 how_is --config CONFIG_FILE --date REPORT_DATE
        EOF

        opts.separator ""
        opts.separator "Options:"

        opts.on("--config CONFIG_FILE",
                "YAML config file for automating reports.") do |filename|
          options[:config] = filename
        end

        opts.on("--repository USER/REPO", REPO_REGEXP,
                "Repository to generate a report for.") do |repository|
          options[:repository] = repository
        end

        opts.on("--date YYYY-MM-DD", DATE_REGEXP,
                "Last date of the report.") do |date|
          options[:date] = date
        end

        formats = HowIs.supported_formats.join(', ')
        opts.on("--output REPORT_FILE", format_regexp,
                "Output file for the report.",
                "Supported file formats: #{formats}.") do |filename, _|
          options[:report] = filename
        end

        opts.on("--verbose", "Print debug information.") do
          options[:verbose] = true
        end

        opts.on("-v", "--version", "Prints version information") do
          options[:version] = true
        end

        opts.on("-h", "--help", "Print help text") do
          options[:help] = true
        end
      end

      # `.parse!` populates the `options` Hash that was created above, and
      # the return value is any non-flag arguments.
      opt_parser.parse!(argv)

      [opts, options]
    end

    def self.validate_options!(options)
      if options[:date] && !options[:repository] && !options[:config]
        missing_argument("expected wither --repository or --config.")
      end

      if !options[:date] && !options[:help] && !options[:version]
        missing_argument("--date")
      end
    end

    def self.format_regexp
      format_regexp_parts =
        HowIs.supported_formats.map { |x| Regexp.escape(x) }

      /.+\.(#{format_regexp_parts.join("|")})/
    end

    def self.missing_argument(argument)
      raise OptionParser::MissingArgument, argument
    end
  end
end
