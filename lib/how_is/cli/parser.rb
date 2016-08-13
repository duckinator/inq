#!/usr/bin/env ruby

require "how_is"
require "how_is/cli"
require "optparse"

class HowIs::CLI
  DEFAULT_OPTIONS = {
    repository: nil,
    report: "report.pdf",
    from: nil,
    config: nil,
  }

  class OptionsError < StandardError
  end

  class Parser
    attr_reader :opts

    def parse!(_argv)
      opts = Slop::Options.new
      opts.banner =
        <<-EOF.gsub(/ *\| ?/, '')
        | Usage: how_is REPOSITORY [--report REPORT_FILE]
        |        how_is --config [CONFIG_FILE]
        |
        | Where REPOSITORY is of the format <GitHub username or org>/<repository name>.
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
      opts.string       "--report",  "output file for the report (valid extensions: #{HowIs.supported_formats.join(', ')})"
      opts.string "-v", "--version", "prints the version"

      parser    = Slop::Parser.new(opts)
      result    = parser.parse(argv)
      options   = DEFAULT_OPTIONS.merge(results.to_hash)
      arguments = result.arguments

      unless options[:config]
        # These are only never used elsewhere; removing them simplifies the
        # contracts and keyword args for other APIs.
        options.delete(:config)
      end


      unless HowIs.can_export_to?(options[:report_file])
        raise OptionsError, "Invalid file: #{options[:report_file]}. Supported formats: #{HowIs.supported_formats.join(', ')}"
      end

      if options[:config]
        # Nothing to do.
      elsif options[:from]
        # Opening this file here seems a bit messy, but it works.
        options[:repository] = JSON.parse(open(options[:from_file]).read)['repository']
        raise OptionsError, "Invalid JSON report file." unless options[:repository]
      elsif argv.length >= 1
        options[:repository] = argv.delete_at(0)
      else
        raise OptionsError, "No repository specified."
      end

      {
        opts: opts,
        options: options,
        arguments: arguments,
      }
    end
  end
end
