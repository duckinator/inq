# frozen_string_literal: true
require 'how_is/contributions'

describe HowIs::Contributions do
  let(:github) { Github.new(auto_pagination: true) }
  let(:user) { 'how-is'}
  let(:repo) { 'example-repository' }
  let(:since_date) { '2017-01-01' }

  let(:contributions) {
    described_class.new(github: github,
                        user: user,
                        repo: repo,
                        since_date: since_date)
  }

  context '#all_contributors' do
    it 'lists the contributors hash keyed by email' do
      VCR.use_cassette('how_is_contributions_all_contributors') do

        expect(contributions.all_contributors.keys).to(
          match_array(['me@duckie.co', 'fake@duckinator.net'])
        )
      end
    end
  end

  context '#new_contributors' do
    it 'lists only the new contributors since the given date' do
      VCR.use_cassette('how_is_contributions_new_contributors') do

        expect(contributions.new_contributors.keys).to(
          match_array(['fake@duckinator.net'])
        )
      end
    end
  end
end
