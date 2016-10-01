#!/usr/bin/env ruby

require "how_is"
require "how_is/cli"
require "slop"

class HowIs::CLI
  DEFAULT_REPORT_FILE = "report.#{HowIs::DEFAULT_FORMAT}"

  class OptionsError < StandardError
  end

  class InvalidOutputFileError < OptionsError
  end

  class InvalidInputFileError < OptionsError
  end

  class NoRepositoryError < OptionsError
  end

  class Parser
    attr_reader :opts

    def call(argv)
      opts = Slop::Options.new
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

      opts.bool   "-h", "--help",    "Print help text"
      opts.string       "--config",  "YAML config file, used to generate a group of reports"
      opts.string       "--from",    "JSON report file, used instead of fetching the data again"
      opts.string       "--report",  "output file for the report (valid extensions: #{HowIs.supported_formats.join(', ')}; default: #{DEFAULT_REPORT_FILE})"
      opts.bool   "-v", "--version", "prints the version"

      parser    = Slop::Parser.new(opts)
      result    = parser.parse(argv)
      options   = result.to_hash
      arguments = result.arguments

      options[:report] ||= DEFAULT_REPORT_FILE

      # The following are only useful if they're not nil or false.
      # Removing them here simplifies contracts and keyword args for other APIs.
      options.delete(:config)   unless options[:config]
      options.delete(:help)     unless options[:help]
      options.delete(:version)  unless options[:version]

      unless HowIs.can_export_to?(options[:report])
        raise InvalidOutputFileError, "Invalid file: #{options[:report_file]}. Supported formats: #{HowIs.supported_formats.join(', ')}"
      end

      unless options[:config]
        # If we pass --config, other options (excluding --help and --version)
        # are ignored. As such, everything in this `unless` block is irrelevant.

        if options[:from]
          raise InvalidInputFileError, "No such file: #{options[:from]}" unless File.file?(options[:from])

          # Opening the file here is a bit gross, but I couldn't find a better
          # way to do it. -@duckinator
          options[:repository] = JSON.parse(open(options[:from_file]).read)['repository']
          raise InvalidInputFileError, "Invalid JSON report file." unless options[:repository]
        elsif argv.length >= 1
          options[:repository] = argv.delete_at(0)
        else
          raise NoRepositoryError, "No repository specified."
        end
      end

      {
        opts: opts,
        options: options,
        arguments: arguments,
      }
    end
  end
end
