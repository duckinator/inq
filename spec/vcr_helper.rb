# frozen_string_literal: true

require "vcr"

VCR.configure do |config|
  # To have VCR re-record all casettes, do `VCR_MODE=rec bundle exec rake test`
  vcr_mode = ENV["VCR_MODE"] =~ /rec/i ? :all : :once

  config.configure_rspec_metadata!

  config.default_cassette_options = {
    record: vcr_mode,
    match_requests_on: [:method, :uri, :body]
  }

  # Filter out the values of 'Authorization:' headers.
  config.filter_sensitive_data("<AUTHORIZATION TOKEN>") { |interaction|
    auth_headers = interaction.request.headers["Authorization"]
    if auth_headers.is_a?(Array) && auth_headers.length > 0
      auth_headers.first
    else
      "<AUTHORIZATION TOKEN>" # idk if you can just return nil here without weirdness?
    end
  }

  config.allow_http_connections_when_no_cassette = false
  config.cassette_library_dir = "fixtures/vcr_cassettes"
  config.hook_into :webmock
end
