# frozen_string_literal: true

require "spec_helper"
require "inq/sources/github_helpers"
require "json"

describe Inq::Sources::GithubHelpers do
  let(:issues) { JSON.parse(open(File.expand_path("../data/issues.json", __dir__)).read) }
  let(:pulls) { JSON.parse(open(File.expand_path("../data/pulls.json", __dir__)).read) }

  let(:fake_issues) { JSON.parse(open(File.expand_path("../data/fake/issues.json", __dir__)).read) }
  # let(:fake_pulls) { JSON.parse(open(File.expand_path('../data/pulls.json', __dir__)).read) }

  subject { Class.new { extend Inq::Sources::GithubHelpers } }

  context "#average_age_for" do
    it "returns the average age for the provided issues or pulls" do
      actual = nil

      date = DateTime.parse("2016-07-07")
      Timecop.freeze(date) do
        actual = subject.average_age_for(fake_issues)
      end

      expected = "approximately 10 years and 6 months"

      expect(actual).to eq(expected)
    end
  end

  context "#oldest_for" do
    it "returns the oldest item for the provided issues or pulls" do
      actual = subject.oldest_for(fake_issues)

      expect(actual["createdAt"]).to eq("1999-01-01T00:00:00Z")
      expect(actual["url"]).to eq("https://github.com/rubygems/rubygems/issues/9001")
    end
  end
end
