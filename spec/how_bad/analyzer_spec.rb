require 'spec_helper'

describe HowBad::Analyzer do
  let(:issues) { JSON.parse(open(File.expand_path('../data/issues.json', __dir__)).read) }
  let(:pulls) { JSON.parse(open(File.expand_path('../data/pulls.json', __dir__)).read) }

  let(:fetcher_results) { HowBad::Fetcher::Results.new(issues, pulls) }

  
end
