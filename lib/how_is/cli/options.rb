#!/usr/bin/env ruby

require "how_is"
require "how_is/cli"
require "optparse"

class HowIs::CLI
  class Options
    def parse(_argv)
      options = {
        repository: nil,
        report_file:  "report.pdf",
        from_file: nil,
        use_config_file: false,
        config_file: nil,
      }

      opts = OptionParser.new do |opts|
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

        opts.on("-h", "--help", "Print this help") do
          puts opts
          exit 0
        end

        opts.on("--config [YAML_CONFIG_FILE]", "generate reports as specified in YAML_CONFIG_FILE") do |file|
          options[:use_config_file] = true
          options[:config_file] = file
        end

        opts.on("--from JSON_REPORT_FILE", "import JSON_REPORT_FILE instead of fetching the data again") do |file|
          options[:from_file] = file
        end

        opts.on("--report REPORT_FILE", "file containing the report") do |file|
          options[:report_file] = file
        end

        opts.on("-v", "--version", "prints the version") do
          puts HowIs::VERSION
          exit
        end
      end

      argv = _argv.clone
      opts.parse!(argv)

      unless options[:use_config_file]
        # These are only never used elsewhere; removing them simplifies the
        # contracts and keyword args for other APIs.
        options.delete(:use_config_file)
        options.delete(:config_file)
      end


      unless HowIs.can_export_to?(options[:report_file])
        abort "Invalid file: #{options[:report_file]}. Supported formats: #{HowIs.supported_formats.join(', ')}"
      end

      if options[:use_config_file]
        # pass
      elsif options[:from_file]
        # Opening this file here seems a bit messy, but it works.
        options[:repository] = JSON.parse(open(options[:from_file]).read)['repository']
        abort "Error: Invalid JSON report file." unless options[:repository]
      elsif argv.length >= 1
        options[:repository] = argv.delete_at(0)
      else
        abort "Error: No repository specified."
      end

      options
    end
  end
end
