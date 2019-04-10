# frozen_string_literal: true

require "digest"

module HowIs
  # Class for use in caching expensive operations
  class Cacheable
    def initialize(config, start_date, end_date, tmpdir = Dir.mktmpdir)
      @config = config
      @start_date = start_date
      @end_date = end_date
      @tmpdir = tmpdir
    end

    def cached(key, extra_digest = nil)
      cache = @config["cache"]
      return yield if cache.nil?

      hash_key = []
      hash_key << Digest::SHA1.hexdigest(extra_digest) if extra_digest
      hash_key << Digest::SHA1.hexdigest(@config.to_json)
      cache_key = File.join(@start_date, @end_date, key, hash_key.join("-"))

      case cache["type"]
      when "marshal"
        MarshalCache.cached(cache_key, @tmpdir) { yield }
      when "self"
        # Can provide your own cache in HowIs.new
        # e.g.
        # cache_mechanism = ->(cache_key, config, block) do
        #   if cached?
        #     cached_value
        #   else
        #     block.call
        #   end
        # end
        # HowIs.new("owner/repo", date, cache_mechanism)
        cache["cache_mechanism"].call(cache_key, @config, ->() { yield })
      end
    end

    # This is only okay on a local system
    module MarshalCache
      class << self
        # rubocop:disable Security/MarshalLoad
        def cached(key, tmpdir)
          require "fileutils"

          path = File.join(tmpdir, "how_is", key)
          FileUtils.mkdir_p(File.dirname(path))

          ret = nil
          if File.exist?(path)
            File.open(path, "rb") do |f|
              ret = Marshal.load(f)
            end
            ret
          else
            ret = yield
            File.open(path, "wb") do |file|
              Marshal.dump(ret, file)
            end
          end
          ret
        end
        # rubocop:enable Security/MarshalLoad
      end
    end
  end
end
