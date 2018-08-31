# NOPE THIS IS BROKEN // frozen_string_literal: // true

require "how_is"
require "optparse"

module HowIs::CLI
  # Parses +argv+ to generate an options Hash to control the behavior of
  # the library.
  def self.parse(argv)
    opts_, options = self.parse_main(argv)
    options = normalize_options(options)

    # Return an Array containing:
    #   +opts+: the original OptionParser object.
    #   +options+: the Hash of flags/values.
    [opts_, options]
  end

  def self.parse_main(argv)
    options = {
      report: HowIs::DEFAULT_REPORT_FILE,
    }
    opts_ = nil

    opt_parser = OptionParser.new do |opts|
      opts_ = opts
      # General usage information.
      opts.banner =
        <<~EOF
          Usage: how_is --repository REPOSITORY --date REPORT_DATE [--output REPORT_FILE]
                 how_is --config CONFIG_FILE --date REPORT_DATE
        EOF

      opts.separator ""
      opts.separator "Options:"

      opts.on("--config CONFIG_FILE",
              "YAML config file for automating reports.") do |filename|
        options[:config] = filename
      end

      opts.on("--repository USER/REPO",
              /.+\/.+/,
              "Repository to generate a report for.") do |repository|
        options[:repository] = repository
      end

      opts.on("--date YYYY-MM-DD",
              /\d\d\d\d-\d\d-\d\d/,
              "Last date of the report.") do |date|
        options[:date] = date
      end

      opts.on("--output REPORT_FILE",
              format_regexp,
              "Output file for the report.",
              "Supported file types: #{HowIs.supported_formats.join(', ')}."
             ) do |filename, _|
        options[:report] = filename
      end

      opts.on("--verbose",
              "Print debug information.") do
        options[:verbose] = true
      end

      opts.on("-v", "--version",
              "Prints version information") do
        options[:version] = true
      end

      opts.on("-h", "--help",
              "Print help text") do
        options[:help] = true
      end
    end

    # `.parse!` populates the `options` Hash that was created above, and
    # the return value is any non-flag arguments.
    opt_parser.parse!(argv)

    [opts_, options]
  end

  def self.normalize_options(options)
    # Options that are mutually-exclusive with everything else.
    options = {:help    => true} if options[:help]
    options = {:version => true} if options[:version]

    if !options[:help] && !options[:version]
      return missing_argument("--date") unless options[:date]
    end

    if (options[:repository] || options[:config]) && !options[:date]
      missing_argument("--date")
    end

    if (!options[:repository] && !options[:config]) && options[:date]
      missing_argument("expected wither --repository or --config.")
    end

    options
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
