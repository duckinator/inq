# frozen_string_literal: true

require "inq/cacheable"

describe Inq::Cacheable do
  around(:example) do |example|
    load_test_env do
      example.run
    end
  end

  let(:marshal_cache_config) do
    config =
      Inq::Config.new
        .load_defaults
        .load({"repository" => "duckinator/inq", "cache" => {"type" => "marshal"}})
  end

  CACHE_HASH = {}
  let(:self_cache_config) do
    config =
      Inq::Config.new
        .load_defaults
        .load({
          "repository" => "duckinator/inq",
          "cache" => {
            "type" => "self",
            "cache_mechanism" => ->(cache_key, _, block) {
              CACHE_HASH[cache_key] ||= block.call
            }
          }
        })
  end

  let(:no_cache_config) do
    config =
      Inq::Config.new
        .load_defaults
        .load({"repository" => "duckinator/inq"})
  end

  describe "#cached" do
    it "caches with Marshal" do
      marshal_cache = described_class.new(marshal_cache_config, "2018-03-01", "2017-04-15")
      x = 0
      2.times do
        marshal_cache.cached("marshal_cache") do
          x += 1
        end
      end
      expect(x).to eq(1)
    end

    it "caches with self" do
      self_cache = described_class.new(self_cache_config, "2018-03-01", "2017-04-15")

      x = 0
      2.times do
        self_cache.cached("self_cache") do
          x += 1
        end
      end
      expect(x).to eq(1)

      digest = Digest::SHA1.hexdigest(self_cache_config.to_json)
      key = "2018-03-01/2017-04-15/self_cache/#{digest}"
      expect(CACHE_HASH[key]).to eq(1)
    end

    it "caches only when opted in" do
      no_cache = described_class.new(no_cache_config, "2018-03-01", "2017-04-15")
      x = 0
      2.times do
        no_cache.cached("no_cache") do
          x += 1 # Will be run twice
        end
      end
      expect(x).to eq(2)
    end
  end
end
