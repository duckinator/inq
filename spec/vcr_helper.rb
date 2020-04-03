# frozen_string_literal: true

require "vcr"

VCR.configure do |config|
  # To have VCR re-record all casettes, do `VCR_MODE=rec bundle exec rake test`
  vcr_mode = ENV["VCR_MODE"] =~ /rec/i ? :all : :once

  config.configure_rspec_metadata!
  allow_http_connections_when_no_cassette = false

  config.default_cassette_options = {
    record: vcr_mode,
    match_requests_on: [:method, :uri, :body]
  }

  config.cassette_library_dir = "fixtures/vcr_cassettes"
  config.hook_into :webmock
end
