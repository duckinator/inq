# frozen_string_literal: true

require "inq"
require "inq/cli"
require "inq/config"
require "inq/text"

module Inq
  module Exe
    def self.run(argv)
      cli = parse_args(argv)
      options = cli.options

      abort cli.help_text if options[:help]
      abort Inq::VERSION_STRING if options[:version]

      execute(options)
    end

    private

    def self.parse_args(argv)
      cli = Inq::CLI.parse(argv)
    rescue OptionParser::ParseError => e
      abort "inq: error: #{e.message}"
    end

    def self.execute(options)
      data = options[:date]
      config = Inq::Config.new

      config.load_defaults unless options[:no_user_config]
      config.load_env if options[:env_config]

      if options[:config]
        config.load_files(options[:config])
      else
        config.load(Inq.default_config(options[:repository]))
      end

      reports = Inq.from_config(config, date)

      files = reports.save_all
      Inq::Text.puts "Saved reports to:"
      files.each { |file| Inq::Text.puts "- #{file}" }
    rescue => e
      raise if options[:verbose]

      warn "inq: error: #{e.message} (Pass --verbose for more details.)"
      warn "  at: #{e.backtrace_locations.first}"
      exit 1
    end
  end
end
