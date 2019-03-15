# frozen_string_literal: true

require "how_is"
require "how_is/constants"
require "okay/simple_opts"

module HowIs
  ##
  # Class for handling the command-line interface for how_is.
  class CLI
    MissingArgument = Class.new(OptionParser::MissingArgument)

    REPO_REGEXP = /.+\/.+/
    DATE_REGEXP = /\d\d\d\d-\d\d-\d\d/

    attr_accessor :options, :help_text

    def self.parse(*args)
      new.parse(*args)
    end

    def initialize
      @options = nil
      @help_text = nil
    end

    # Parses +argv+ to generate an options Hash to control the behavior of
    # the library.
    def parse(argv)
      parser, options = parse_main(argv)

      # Options that are mutually-exclusive with everything else.
      options = {:help    => true} if options[:help]
      options = {:version => true} if options[:version]

      validate_options!(options)

      @options = options
      @help_text = parser.to_s

      self
    end

    private

    # parse_main() is as short as can be managed. It's fine as-is.
    # rubocop:disable Metrics/MethodLength

    # Carries most of the weight for parse().
    def parse_main(argv)
      defaults = {
        report: HowIs::DEFAULT_REPORT_FILE,
      }

      opts = Okay::SimpleOpts.new(defaults: defaults)

      opts.banner = <<~EOF
        Usage: how_is --repository REPOSITORY --date REPORT_DATE [--output REPORT_FILE]
               how_is --config CONFIG_FILE --date REPORT_DATE
      EOF

      opts.separator "\nOptions:"

      opts.simple("--config CONFIG_FILE",
                  "YAML config file for automated reports.",
                  :config)

      opts.simple("--no-user-config",
                  "Don't load user configuration file.",
                  :no_user_config)

      opts.simple("--env-config",
                  "Use environment variables for configuration.",
                  "Read first: https://how-is.github.io/config",
                  :env_login)

      opts.simple("--repository USER/REPO", REPO_REGEXP,
                  "Repository to generate a report for.",
                  :repository)

      opts.simple("--date YYYY-MM-DD", DATE_REGEXP, "Last date of the report.",
                  :date)

      opts.simple("--output REPORT_FILE", format_regexp,
                  "Output file for the report.",
                  "Supported file formats: #{formats}.",
                  :report)

      opts.simple("--verbose", "Print debug information.", :verbose)
      opts.simple("-v", "--version", "Prints version information.", :version)
      opts.simple("-h", "--help", "Print help text.", :help)

      [opts, opts.parse(argv)]
    end

    # rubocop:enable Metrics/MethodLength

    def validate_options!(options)
      return if options[:help] || options[:version]
      raise MissingArgument, "--date" unless options[:date]
      raise MissingArgument, "--repository or --config" unless
        options[:repository] || options[:config]
    end

    def formats
      HowIs.supported_formats.join(", ")
    end

    def format_regexp
      regexp_parts = HowIs.supported_formats.map { |x| Regexp.escape(x) }

      /.+\.(#{regexp_parts.join("|")})/
    end
  end
end
