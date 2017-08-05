# frozen_string_literal: true

require "vcr"

VCR.configure do |config|
  config.default_cassette_options = {
    record: :new_episodes,
  }

  config.cassette_library_dir = "fixtures/vcr_cassettes"
  config.hook_into :webmock
end
