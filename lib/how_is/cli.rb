# NOPE THIS IS BROKEN // frozen_string_literal: // true

require "how_is"
require "optparse"

module HowIs::CLI
  # Parses +argv+ to generate an options Hash to control the behavior of
  # the library.
  def self.parse(argv)
    options = {
      report: HowIs::DEFAULT_REPORT_FILE,
    }
    opts_ = nil

    opt_parser = OptionParser.new do |opts|
      opts_ = opts
      # General usage information.
      opts.banner =
        <<-EOF.gsub(/ *\| ?/, '')
        | Usage: how_is --repository REPOSITORY --date REPORT_DATE [--output REPORT_FILE]
        |        how_is --config CONFIG_FILE --date REPORT_DATE
        |
        | Where REPOSITORY is of the format GITHUB_USERNAME/REPO_NAME.
        |
        | E.g., to generate a report for how-is/how_is for Nov 01 2016
        | through Dec 01 2016, you'd run:
        |     how_is how-is/how_is --date 2016-12-01
        |
        | Valid extensions: #{HowIs.supported_formats.join(', ')}.
      EOF

      opts.separator ""
      opts.separator "Options:"

      opts.on("--config CONFIG_FILE",
              "YAML config file for automating reports.") do |filename|
        options[:config] = filename
      end

      opts.on("--repository REPOSITORY",
              /.+\/.+/,
              "Repository to generate a report for.") do |repository|
        options[:repository] = repository
      end

      supported_format_regexp =
        HowIs.supported_formats
          .map(&Regexp.method(:escape))
          .join("|")
      opts.on("--output REPORT_FILE",
              /.+\.(#{supported_format_regexp})/,
              "Output file for the report.") do |filename|
        options[:report] = filename
      end

      opts.on("--date DATE",
              /\d\d\d\d-\d\d-\d\d/,
              "Last date of the report, in the format YYYY-MM-DD") do |date|
        options[:date] = date
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

    # Return an Array containing:
    #   +opts+: the original OptionParser object.
    #   +options+: the Hash of flags/values.
    [opts_, options]
  end

  def self.missing_argument(argument)
    raise OptionParser::MissingArgument, argument
  end
end
