$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'how_is'
require 'timecop'
#require 'vcr'

#VCR.configure do |config|
#  config.cassette_library_dir = "fixtures/vcr_cassettes"
#  config.hook_into :webmock
#end

require File.expand_path('./vcr_helper.rb', __dir__)
