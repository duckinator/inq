require 'spec_helper'

describe HowIs::Analyzer do
  let(:issues) { JSON.parse(open(File.expand_path('../data/issues.json', __dir__)).read) }
  let(:pulls) { JSON.parse(open(File.expand_path('../data/pulls.json', __dir__)).read) }

  let(:fake_issues) { JSON.parse(open(File.expand_path('../data/fake/issues.json', __dir__)).read) }
  #let(:fake_pulls) { JSON.parse(open(File.expand_path('../data/pulls.json', __dir__)).read) }

  let(:fetcher_results) { HowIs::Fetcher::Results.new(issues, pulls) }

  subject { HowIs::Analyzer.new }

  context '#num_with_label' do
    it 'returns a Hash mapping labels to the number of issues or pulls with that label' do
      actual   = subject.num_with_label(fake_issues)
      expected = {"triage" => 3, "administrative" => 2}

      expect(actual).to eq(expected)
    end
  end

  context '#average_date_for' do
   it 'returns the average date for the provided issues or pulls' do
     actual   = subject.average_date_for(fake_issues)
     expected = DateTime.parse('2006-01-01')

     expect(actual).to eq(expected)
   end
  end

  context '#average_age_for' do
   it 'returns the average age for the provided issues or pulls' do
     actual   = subject.average_age_for(fake_issues)
     expected = "approximately 10 years and 6 months"

     expect(actual).to eq(expected)
   end
  end

  context '#oldest_for' do
    it 'returns the oldest item for the provided issues or pulls' do
      actual = subject.oldest_for(fake_issues)
      expected = JSON.parse(open(File.expand_path('../data/how_is/analyzer_spec/oldest_for.json', __dir__)).read)

      expect(actual).to eq(expected)
    end
  end
end
