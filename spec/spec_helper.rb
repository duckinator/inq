$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'how_is'
require 'timecop'

RSpec.configure do |config|
  # For tags. https://engineering.sharethrough.com/blog/2013/08/10/greater-test-control-with-rspecs-tag-filters/
  config.treat_symbols_as_metadata_keys_with_true_values = true
end
