require "how_is"
require "slop"

class HowIs::CLI
  DEFAULT_REPORT_FILE = "report.#{HowIs::DEFAULT_FORMAT}"

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
  class NoRepositoryError < OptionsError
  end

  # Parses +argv+ to generate an options Hash to control the behavior of
  # the library.
  def self.parse(argv)
    opts = Slop::Options.new

    # General usage information.
    opts.banner =
      <<-EOF.gsub(/ *\| ?/, '')
        | Usage: how_is REPOSITORY [--report REPORT_FILE] [--from JSON_FILE]
        |        how_is --config CONFIG_FILE
        |
        | Where REPOSITORY is <GitHub username or org>/<repository name>.
        | CONFIG_FILE defaults to how_is.yml.
        |
        | E.g., if you wanted to check https://github.com/how-is/how_is,
        | you'd run `how_is how-is/how_is`.
        |
      EOF

    opts.separator ""
    opts.separator "Options:"

    # Allowed arguments:
    opts.bool   "-h", "--help",    "Print help text"
    opts.string       "--config",  "YAML config file, used to generate a group of reports"
    opts.string       "--from",    "JSON report file, used instead of fetching the data again"
    opts.string       "--report",  "output file for the report (valid extensions: #{HowIs.supported_formats.join(', ')}; default: #{DEFAULT_REPORT_FILE})"
    opts.bool   "-v", "--version", "prints the version"

    # Parse the arguments.
    parser    = Slop::Parser.new(opts)
    result    = parser.parse(argv)

    # +options+ is a Hash of flags/values.
    options   = result.to_hash
    # +arguments+ is an Array of values that don't correspond to a flag.
    arguments = result.arguments

    # If --report isn't specified, default to DEFAULT_REPORT_FILE.
    options[:report] ||= DEFAULT_REPORT_FILE

    # The following are only useful if they're not nil or false.
    # Removing them here simplifies contracts and keyword args for
    # other APIs.
    options.delete(:config)   unless options[:config]
    options.delete(:help)     unless options[:help]
    options.delete(:version)  unless options[:version]

    # If we can't export to the specified file, raise an exception.
    unless HowIs.can_export_to?(options[:report])
      raise InvalidOutputFileError, "Invalid file: #{options[:report]}. Supported formats: #{HowIs.supported_formats.join(', ')}"
    end

    # If we pass --config, other options (excluding --help and
    # --version) are ignored. As such, when --config is passed,
    # everything in this `unless` block is irrelevant.
    unless options[:config]
      if options[:from]
        raise InvalidInputFileError, "No such file: #{options[:from]}" unless File.file?(options[:from])

        # Opening the file here is a bit gross, but I couldn't find a
        # better way to do it. -@duckinator
        options[:repository] = JSON.parse(open(options[:from]).read)['repository']

        raise InvalidInputFileError, "Invalid JSON report file." unless options[:repository]

      elsif argv.length >= 1
        options[:repository] = argv.delete_at(0)

      else
        raise NoRepositoryError, "No repository specified."
      end
    end

    # Return a Hash with:
    #   +opts+: the original Slop::Options object.
    #   +options+: the Hash of flags/values (e.g. +--foo bar+ becomes
    #     +options[:foo]+ with the value of +"bar"+).
    #   +arguments+: an Array of arguments that don't have a
    #     corresponding flags.
    {
      opts: opts,
      options: options,
      arguments: arguments,
    }
  end
end
