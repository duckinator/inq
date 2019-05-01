# frozen_string_literal: true

require "inq"
require "inq/constants"
require "okay/simple_opts"

module Inq
  ##
  # Parses command-line arguments for inq.
  class CLI
    MissingArgument = Class.new(OptionParser::MissingArgument)

    REPO_REGEXP = /.+\/.+/
    DATE_REGEXP = /\d\d\d\d-\d\d-\d\d/

    attr_reader :options, :help_text

    def self.parse(*args)
      new.parse(*args)
    end

    def initialize
      @options = nil
      @help_text = nil
    end

    # Parses an Array of command-line arguments into an equivalent Hash.
    #
    # The results of this can be used to control the behavior of the rest
    # of the library.
    #
    # @params argv [Array] An array of command-line arguments, e.g. +ARGV+.
    # @return [Hash] A Hash containing data used to control Inq's behavior.
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

    # This does a significant chunk of the work for parse().
    #
    # @return [Array] An array containing the +OptionParser+ and the result
    #   of running it.
    def parse_main(argv)
      defaults = {
        report: Inq::DEFAULT_REPORT_FILE,
      }

      opts = Okay::SimpleOpts.new(defaults: defaults)

      opts.banner = <<~EOF
        Usage: inq --repository REPOSITORY --date REPORT_DATE [--output REPORT_FILE]
               inq --config CONFIG_FILE --date REPORT_DATE
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

    # Given an +options+ Hash, determine if we got a valid combination of
    # options.
    #
    # 1. Anything with `--help` and `--version` is always valid.
    # 2. Otherwise, `--repository` or `--config` is required.
    # 3. If `--repository` or `--config` is required, so is `--date`.
    #
    # @param options [Hash] The result of CLI#parse().
    # @raise [MissingArgument] if we did not get a valid options Hash.
    def validate_options!(options)
      return if options[:help] || options[:version]
      raise MissingArgument, "--date" unless options[:date]
      raise MissingArgument, "--repository or --config" unless
        options[:repository] || options[:config]
    end

    # @return [String] A comma-separated list of supported formats.
    def formats
      Inq.supported_formats.join(", ")
    end

    # @return [Regexp] a +Regexp+ object which matches any path ending
    #   with an extension corresponding to a supported format.
    def format_regexp
      regexp_parts = Inq.supported_formats.map { |x| Regexp.escape(x) }

      /.+\.(#{regexp_parts.join("|")})/
    end
  end
end
