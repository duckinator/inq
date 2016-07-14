require 'spec_helper'

describe HowIs do
  let(:issues) { JSON.parse(open(File.expand_path('./data/issues.json', __dir__)).read) }
  let(:pulls) { JSON.parse(open(File.expand_path('./data/pulls.json', __dir__)).read) }

  let(:github) {
    instance_double('GitHub',
      issues: instance_double('GitHub::Issues', list: issues),
      pulls: instance_double('GitHub::Pulls', list: pulls)
    )
  }


  context '.generate_report' do
    it 'generates a correct JSON report' do
      actual = HowIs.generate_report(
        repository: 'rubygems/rubygems',
        github: github,
        format: :json,
      )

      expected = open(File.expand_path('./data/how_is_spec/generate_report--generates-a-correct-JSON-report.json', __dir__)).read.strip

      expect(actual).to eq(expected)
    end
  end
end
