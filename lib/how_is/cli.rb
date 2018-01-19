# NOPE THIS IS BROKEN // frozen_string_literal: // true

require "how_is"
require "optparse"

module HowIs::CLI
  # Parent class of all exceptions raised in HowIs::CLI.
  class OptionsError < StandardError
  end

  # Raised when the specified output file can't be used.
  class InvalidOutputFileError < OptionsError
  end

  # Raised when the specified input file doesn't contain
  # a valid JSON report.
  class InvalidInputFileError < OptionsError
  end

  # Raised when no repository is specified, but one is required.
  # (It's _not_ required, e.g., when +--config+ is passed.)
  class HowIsArgumentError < OptionsError
  end

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
        | Usage: how_is REPOSITORY REPORT_DATE [--output REPORT_FILE]
        |        how_is REPORT_DATE --config CONFIG_FILE
        |
        | Where:
        |   REPOSITORY is <GitHub username or org>/<repository name>.
        | and
        |   REPORT_DATE is the last day the report covers, in the format YYYY-mm-dd.
        |
        | E.g., if you wanted to check https://github.com/how-is/how_is for
        | November 01 2016 through December 01 2016, you'd run:
        |   how_is how-is/how_is 2016-12-01
        |
      EOF

      opts.separator ""
      opts.separator "Options:"

      # The extra spaces make this a lot easier to comprehend, so we don't want
      # RuboCop to complain about them.
      #
      # Same for line length.
      #
      # rubocop:disable Style/SpaceBeforeFirstArg
      # rubocop:disable Metrics/LineLength

      opts.on("--config CONFIG_FILE",
              "YAML config file, used to generate a group of reports") do |filename|
        options[:config] = filename
      end

      opts.on("--output REPORT_FILE",
              "Output file for the report (valid extensions: #{HowIs.supported_formats.join(', ')}; default: #{HowIs::DEFAULT_REPORT_FILE})") do |filename|
        options[:report] = filename
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
    # rubocop:enable Style/SpaceBeforeFirstArg
    # rubocop:enable Metrics/LineLength

    # `.parse!` populates the `options` Hash that was
    # created above, and the return value is any non-flag
    # arguments.
    arguments = opt_parser.parse!(argv)

    # TODO: Should this raise an exception instead?
    keep_only = lambda { |options_, key| options_.select { |k, v| k == key } }

    if options[:help]
      # If --help is passed, _only_ accept --help.
      options = keep_only.call(options, :help)
    elsif options[:version]
      # If --version is passed, _only_ accept --version.
      options = keep_only.call(options, :version)
    elsif options[:config]
      # If --config is passed, _only_ accept --config.
      options = keep_only.call(options, :config)
      if argv.length >= 1
        options[:date] = argv.delete_at(0)
      else
        raise HowIsArgumentError, "Expected date."
      end
    else
      # If we get here, we're generating a report from the command line,
      # without using --from or --config.

      # If --report isn't specified, default to HowIs::DEFAULT_REPORT_FILE.
      options[:report] ||= HowIs::DEFAULT_REPORT_FILE

      # If we can't export to the specified file, raise an exception.
      unless HowIs.can_export_to?(options[:report])
        raise InvalidOutputFileError, "Invalid file: #{options[:report]}. Supported formats: #{HowIs.supported_formats.join(', ')}"
      end

      if argv.length >= 2
        options[:repository] = argv.delete_at(0)
        options[:date] = argv.delete_at(0)
      else
        raise HowIsArgumentError, "Expected both repository and date."
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
end
