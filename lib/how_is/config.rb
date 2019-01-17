# frozen_string_literal: true

require "yaml"

module HowIs
  HOME_CONFIG = File.join(Dir.home, '.config', 'how_is', 'config.yml')

  class Config < Hash
    attr_reader :site_configs

    def self.with_defaults
      self.new.with_site_configs(HOME_CONFIG)
    end

    def initialize
      super()
      @site_configs = []
    end

    def with_site_configs(*files)
      if files.length == 1 && files[0].is_a?(Array)
        files = files[0]
      end

      load_files(*files)
    end

    def load_files(*file_paths)
      files = (site_configs + file_paths).map { |f| Pathname.new(f) }
      # TODO: Validate config state in some way.
      configs = files.map { |file| YAML.load(file.read) }

      load(*configs)
    end

    def load(*configs)
      configs.each do |config|
        config.each do |k, v|
          self[k] = v
        end
      end

      self
    end
  end

  class ConfigBuilder
    def new(user_config: true)
      @user_config = user_config
    end
  end
end
