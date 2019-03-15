# frozen_string_literal: true

require "yaml"

module HowIs
  HOME_CONFIG = File.join(Dir.home, ".config", "how_is", "config.yml")

  # Usage:
  #     HowIs::Config
  #       .load_site_configs("/path/to/config1.yml", "/path/to/config2.yml")
  #       .load_file("./repo-config.yml")
  # Or:
  #     HowIs::Config
  #       .load_defaults
  #       .load_file("./repo-config.yml")
  # Or:
  #     HowIs::Config
  #       .load_defaults
  #       .load({"repository" => "how-is/example-repository"})
  class Config < Hash
    attr_reader :site_configs

    def self.load_defaults
      new.load_site_configs(HOME_CONFIG)
    end

    def initialize
      super()
      @site_configs = []
    end

    def load_site_configs(*files)
      # Allows both:
      #   load_site_configs('foo', 'bar')
      #   load_site_configs(['foo', bar'])
      # but not:
      #   load_site_configs(['foo'], 'bar')
      files = files[0] if files.length == 1 && files[0].is_a?(Array)

      load_files(*files)
    end

    def load_files(*file_paths)
      files = (site_configs + file_paths).map { |f| Pathname.new(f) }

      # Keep only files that exist.
      files.select!(&:file?)

      # Load the YAML files into Hashes.
      configs = files.map { |file| YAML.safe_load(file.read) }

      # Apply configs.
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

    def load_env
      gh_token = ENV["HOW_IS_GITHUB_TOKEN"]
      gh_username = ENV["HOW_IS_GITHUB_USERNAME"]

      raise "HOW_IS_GITHUB_TOKEN environment variable is not set" \
        unless gh_token
      raise "HOW_IS_GITHUB_USERNAME environment variable is not set" \
        unless gh_username

      load({
        "sources/github" => {
          "username" => github_username,
          "token" => github_token,
        },
      })
    end
  end
end
