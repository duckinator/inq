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
      report = HowIs.generate_report(
        repository: 'rubygems/rubygems',
        github: github,
        format: :json,
      )

      expected_report = {
        "repository" => "rubygems/rubygems",
        "number_of_issues" => 30,
        "number_of_pulls" => 30,
        "issues_with_label" => {
          "triage" => 7,
          "bug report" => 9,
          "feedback" => 4,
          "osx" => 1,
          "bug fix" => 4,
          "category - install" => 5,
          "feature implementation" => 2,
          "major bump" => 2,
          "windows" => 1,
          "feature request" => 1,
          "cleanup" => 1,
          "accepted" => 2,
          "category - #gem or #require" => 1,
          "ready for work" => 1,
          "question" => 3,
          "administrative" => 1
        },
        "issues_with_no_label" => 0,
        "average_issue_age" => "approximately 3 months and 1 week",
        "average_pull_age" => "approximately 11 months and 3 days",
        "oldest_issue_date" => "2016-01-31T21:28:02+00:00",
        "oldest_pull_date" => "2013-09-16T15:04:07+00:00"
      }.to_json

      expect(report).to eq(expected_report)
    end
  end
end
