# frozen_string_literal: true

require "inq"
require "inq/cli"
require "inq/config"
require "inq/text"

module Inq
  ##
  # A module which implements the entire command-line interface for Inq.
  module Exe
    def self.run(argv)
      cli = parse_args(argv)
      options = cli.options

      abort cli.help_text if options[:help]
      abort Inq::VERSION_STRING if options[:version]

      execute(options)
    end

    def self.parse_args(argv)
      Inq::CLI.parse(argv)
    rescue OptionParser::ParseError => e
      abort "inq: error: #{e.message}"
    end
    private_class_method :parse_args

    def self.load_config(options)
      config = Inq::Config.new

      config.load_defaults unless options[:no_user_config]
      config.load_env if options[:env_config]

      if options[:config]
        config.load_files(options[:config])
      else
        config.load(Inq.default_config(options[:repository]))
      end

      config
    end
    private_class_method :load_config

    def self.save_reports(reports)
      files = reports.save_all
      Inq::Text.puts "Saved reports to:"
      files.each { |file| Inq::Text.puts "- #{file}" }
    end
    private_class_method :save_reports

    def self.execute(options)
      date = options[:date]
      config = load_config(options)
      reports = Inq.from_config(config, date)
      save_reports(reports)
    rescue => e
      raise if options[:verbose]

      warn "inq: error: #{e.message} (Pass --verbose for more details.)"
      warn "  at: #{e.backtrace_locations.first}"
      exit 1
    end
    private_class_method :execute
  end
end
