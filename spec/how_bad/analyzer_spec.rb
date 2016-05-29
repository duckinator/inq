require 'spec_helper'

describe HowBad::Analyzer do
  let(:issues) { JSON.parse(open(File.expand_path('../data/issues.json', __dir__)).read) }
  let(:pulls) { JSON.parse(open(File.expand_path('../data/pulls.json', __dir__)).read) }

  let(:fake_issues) { JSON.parse(open(File.expand_path('../data/fake/issues.json', __dir__)).read) }
  #let(:fake_pulls) { JSON.parse(open(File.expand_path('../data/pulls.json', __dir__)).read) }

  let(:fetcher_results) { HowBad::Fetcher::Results.new(issues, pulls) }

  subject { HowBad::Analyzer.new }

  context '#num_with_label' do
    it 'returns a Hash mapping labels to the number of issues or pulls with that label' do
      result = subject.num_with_label(issues)

      expect(result).to eq(TODO)
    end
  end

  context '#average_age_for' do
   it 'returns the average age for the provided issues or pulls' do
     result = subject.average_age_for(fake_issues)

     expect(result).to eq(TODO)
   end
  end

  context '#oldest_date_for' do
    it 'returns the oldest date for the provided issues or pulls' do
      result = subject.oldest_date_for(fake_issues)
      actual_oldest_date = DateTime.parse(fake_issues[0]['created_at'])

      expect(result).to eq(actual_oldest_date)
    end
  end
end
