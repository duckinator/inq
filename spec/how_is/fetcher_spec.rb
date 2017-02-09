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

  let(:pulse) {
    Class.new {
      def html_summary
        'html_summary'
      end
    }.new
  }

  context '#call' do
    it 'returns a hash containing issues and pull requests' do
      actual = subject.call('user/repo', github, pulse)

      expect(actual[:issues]).to eq(issues)
      expect(actual[:pulls]).to eq(pulls)
      expect(actual[:pulse]).to eq('html_summary')
    end
  end
end
