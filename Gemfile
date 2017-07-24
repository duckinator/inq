# frozen_string_literal: true

source "https://rubygems.org"

# how_is only supports Ruby versions receiving general bug fixes ("normal
# maintenance"). This should be updated when a Ruby version goes into security
# maintenance. Ruby maintenance: https://www.ruby-lang.org/en/downloads/branches/
ruby "~> 2.3"

# Specify your gem's dependencies in how_is.gemspec
gemspec

# TODO: move Pry back to gemspec, once a version is released that does not rely
# on an ancient version of Slop. Reason: gemspecs can not handle git deps.
group :development do
  gem "pry", git: "https://github.com/pry/pry.git"
end
