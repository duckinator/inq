# frozen_string_literal: true

require "yaml"

module HowIs
  HOME_CONFIG = File.join(Dir.home, '.config', 'how_is', 'config.yml')

  class Config
    attr_reader :site_configs

    def initialize
      @site_configs = []
    end

    def with_site_configs(*configs)
      if configs.length == 1 && configs[0].is_a?(Array)
        configs = configs[0]
      end

      @site_configs += configs
    end

    def load(*file_paths)
      files = (site_configs + file_paths).map(&Pathname)
      # TODO: Validate config state in some way.
      configs = files.map { |file| YAML.parse(file) }
      final_config = {}

      configs.each do |config|
        config.each do |k, v|
          final_config[k] = v
        end
      end

      final_config
    end

  end

  class ConfigBuilder
    def new(user_config: true)
      @user_config = user_config
    end
  end
end
