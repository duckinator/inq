require 'digest'

module HowIs
  class Cacheable
    def initialize(config, start_date, end_date)
      @config = config
      @start_date = start_date
      @end_date = end_date
    end

    def cached(key, extra_digest = nil)
      cache = @config['cache']
      return yield if cache.nil?

      hash_key = []
      hash_key << Digest::SHA1.hexdigest(extra_digest) if extra_digest
      hash_key << Digest::SHA1.hexdigest(@config.to_json)
      cache_key = File.join(@start_date, @end_date, key, hash_key.join('-'))

      case cache['type']
      when 'marshal'
        MarshalCache.cached(cache_key, @config) { yield }
      when 'redis'
        RedisCache.cached(cache_key) { yield }
      when 'memcache'
        MemcachedCache.cached(cache_key) { yield }
      end
    end

    # This is only okay on a local system
    module MarshalCache
      class << self
        def cached(key, config)
          require 'fileutils'

          path = File.join(base_cache_dir(config), key)
          FileUtils.mkdir_p(File.dirname(path))

          if File.exist?(path)
            ret = nil
            File.open(path,"rb") do |f|
              ret = Marshal.load(f)
            end
            ret
          else
            ret = yield
            File.open(path, "wb") do |file|
              Marshal.dump(ret, file)
            end
            ret
          end
        end

        private

        def base_cache_dir(config)
          File.join("/tmp/how_is", config['repository'])
        end
      end
    end

    module RedisCache
      class << self
        def cached(key, config)
          require 'redis'
          redis = Redis.new(cache['config'])

          if o = redis.get(key)
            Marshal.load(o)
          else
            ret = yield
            redis.set(key, Marshal.dump(ret))
            ret
          end
        end
      end
    end

    module MemcacheCache
      class << self
        def cached(key, config)
          require 'memcached'
          memcache = Memcached.new(cache['config'])

          if o = memcache.get(key)
            Marshal.load(o)
          else
            ret = yield
            memcache.set(key, Marshal.dump(ret))
            ret
          end
        end
      end
    end
  end
end
