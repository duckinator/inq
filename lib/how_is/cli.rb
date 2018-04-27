# NOPE THIS IS BROKEN // frozen_string_literal: // true

require "how_is"
require "optparse"

module HowIs::CLI
  # Parses +argv+ to generate an options Hash to control the behavior of
  # the library.
  def self.parse(argv)
    options = {}
    opts_ = nil

    opt_parser = OptionParser.new do |opts|
      opts_ = opts
      # General usage information.
      opts.banner =
        <<-EOF.gsub(/ *\| ?/, '')
        | Usage: how_is REPOSITORY --date REPORT_DATE [--output REPORT_FILE]
        |        how_is --config CONFIG_FILE --date REPORT_DATE
        |
        | Where REPOSITORY is <GitHub username or org>/<repository name>.
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

      opts.on("--output REPORT_FILE",
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
    arguments = opt_parser.parse!(argv)

    # Options that are mutually-exclusive with everything else.
    options = {:help    => true} if options[:help]
    options = {:version => true} if options[:version]

    if !options[:help] && !options[:version]
      return missing_argument("--date") unless options[:date]
      return missing_argument("REPOSITORY") if argv.length.zero?

      # If --report isn't specified, default to HowIs::DEFAULT_REPORT_FILE.
      options[:report] ||= HowIs::DEFAULT_REPORT_FILE

      file_format = File.extname(options[:report])[1..-1]
      unless HowIs.supported_format?(file_format)
        raise OptionParser::InvalidArgument, "unsupported format: #{file_format}"
      end
    end

    # Return a Hash with:
    #   +opts+: the original Slop::Options object.
    #   +options+: the Hash of flags/values (e.g. +--foo bar+ becomes
    #     +options[:foo]+ with the value of +"bar"+).
    #   +arguments+: an Array of arguments that don't have a
    #     corresponding flags.
    {
      opts: opts_,
      options: options,
      arguments: arguments,
    }
  end

  def self.missing_argument(argument)
    raise OptionParser::MissingArgument, argument
  end
end
