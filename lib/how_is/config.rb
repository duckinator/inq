# frozen_string_literal: true

require "yaml"
require "how_is/text"

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

    # If the +HOWIS_USE_ENV+ environment variable is set, load config from
    # the environment.
    #
    # Otherwise, load the the default config file.
    #
    # @return [Hash] A Hash representation of the config.
    def load_defaults
      if ENV["HOWIS_USE_ENV"] == "true"
        load_env
      else
        load_site_configs(HOME_CONFIG)
      end
    end

    def initialize
      super()
      @site_configs = []
    end

    # Load the config files as specified via +files+.
    #
    # @param files [Array<String>] The path(s) for config files.
    # @return [Config] The config hash. (+self+)
    def load_site_configs(*files)
      # Allows both:
      #   load_site_configs('foo', 'bar')
      #   load_site_configs(['foo', bar'])
      # but not:
      #   load_site_configs(['foo'], 'bar')
      files = files[0] if files.length == 1 && files[0].is_a?(Array)

      load_files(*files)
    end

    # TODO: See if this can be consolidated with load_site_configs.
    def load_files(*file_paths)
      files = (site_configs + file_paths).map { |f| Pathname.new(f) }

      # Keep only files that exist.
      files.select!(&:file?)

      # Load the YAML files into Hashes.
      configs = files.map { |file| YAML.safe_load(file.read) }

      # Apply configs.
      load(*configs)
    end

    # Take a collection of config hashes and cascade them, meaning values
    # in later ones override values in earlier ones.
    #
    # E.g., this results in +{'a'=>'x', 'c'=>'d'}+:
    #     load({'a'=>'b'}, {'c'=>'d'}, {'a'=>'x'})
    #
    # @param [Array<Hash>] The configuration hashes.
    # @return [Config] The final configuration value.
    def load(*configs)
      configs.each do |config|
        config.each do |k, v|
          self[k] = v
        end
      end

      self
    end

    # Load config info from environment variables.
    #
    # Supported environment variables:
    # - HOWIS_GITHUB_TOKEN: a GitHub authentication token.
    # - HOWIS_GITHUB_USERNAME: the GitHub username corresponding to the token.
    #
    # @return [Config] The resulting configuration.
    def load_env
      HowIs::Text.puts "Using configuration from environment variables."

      gh_token = ENV["HOWIS_GITHUB_TOKEN"]
      gh_username = ENV["HOWIS_GITHUB_USERNAME"]

      raise "HOWIS_GITHUB_TOKEN environment variable is not set" \
        unless gh_token
      raise "HOWIS_GITHUB_USERNAME environment variable is not set" \
        unless gh_username

      load({
        "sources/github" => {
          "username" => gh_username,
          "token" => gh_token,
        },
      })
    end
  end
end
