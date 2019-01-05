# frozen_string_literal: true

require "how_is"
require "how_is/simple_opts"

module HowIs
  ##
  # Class for handling the command-line interface for how_is.
  class CLI
    MissingArgument = Class.new(OptionParser::MissingArgument)

    REPO_REGEXP = /.+\/.+/
    DATE_REGEXP = /\d\d\d\d-\d\d-\d\d/

    attr_accessor :options, :help_text, :version_text

    def initialize
      @parser = nil
      @options = nil
      @help_text = nil
    end

    # Parses +argv+ to generate an options Hash to control the behavior of
    # the library.
    def parse(argv)
      opts, options = parse_main(argv)

      # Options that are mutually-exclusive with everything else.
      options = {:help    => true} if options[:help]
      options = {:version => true} if options[:version]

      validate_options!(options)

      @options = options
      @parser = opts
      @help_text = @parser.to_s

      self
    end

    def parse_main(argv)
      defaults = {
        report: HowIs::DEFAULT_REPORT_FILE,
      }

      opts = SimpleOpts.new(defaults: defaults)

      opts.banner = <<~EOF
        Usage: how_is --repository REPOSITORY --date REPORT_DATE [--output REPORT_FILE]
               how_is --config CONFIG_FILE --date REPORT_DATE
      EOF

      opts.separator "\nOptions:"

      opts.simple("--config CONFIG_FILE",
                  "YAML config file for automated reports.",
                  :config)

      opts.simple("--repository USER/REPO", REPO_REGEXP,
                  "Repository to generate a report for.",
                  :repository)

      opts.simple("--date YYYY-MM-DD", DATE_REGEXP, "Last date of the report.",
                  :date)

      opts.simple("--output REPORT_FILE", HowIs::CLI.format_regexp,
                  "Output file for the report.",
                  "Supported file formats: #{HowIs::CLI.formats}.",
                  :report)

      opts.simple("--verbose", "Print debug information.", :verbose)
      opts.simple("-v", "--version", "Prints version information.", :version)
      opts.simple("-h", "--help", "Print help text.", :help)

      [opts, opts.parse(argv)]
    end

    def validate_options!(options)
      return if options[:help] || options[:version]
      raise MissingArgument, "--date" unless options[:date]
      raise MissingArgument, "--repository or --config" unless
        options[:repository] || options[:config]
    end

    def self.formats
      HowIs.supported_formats.join(", ")
    end

    def self.format_regexp
      format_regexp_parts =
        HowIs.supported_formats.map { |x| Regexp.escape(x) }

      /.+\.(#{format_regexp_parts.join("|")})/
    end

    def self.parse(*args)
      new.parse(*args)
    end
  end
end
