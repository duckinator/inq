require 'spec_helper'
require 'json'

describe HowIs::Fetcher do
  let(:issues) { JSON.parse(open(File.expand_path('../data/issues.json', __dir__)).read) }
  let(:pulls) { JSON.parse(open(File.expand_path('../data/pulls.json', __dir__)).read) }

  let(:github) {
    instance_double('GitHub',
      issues: instance_double('GitHub::Issues', list: issues),
      pulls: instance_double('GitHub::Pulls', list: pulls)
    )
  }

  context '#call' do
    it 'returns a hash containing issues and pull requests' do
      results = subject.call('user/repo', github)
      expect(results[:issues]).to eq(issues)
      expect(results[:pulls]).to eq(pulls)
    end
  end
end
