# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in how_is.gemspec
gemspec

gem "bundler"
gem "rake"

group :development do
  gem "github_changelog_generator"
  gem "pry", git: "https://github.com/pry/pry.git"
  gem "rubocop", "~> 0.49.1"
end

group :test, :development do
  gem "rspec"
  gem "timecop"
  gem "vcr"
  gem "webmock"
end
