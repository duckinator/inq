#!/usr/bin/env ruby

# frozen_string_literal: true

require "bundler/setup" # to avoid having to do `bundle exec ...`
require "inq/sources/ci/travis"
require "inq/sources/ci/appveyor"
require "pp"

travis = Inq::Sources::CI::Travis.new("rubygems/rubygems", "2018-12-01", "2019-02-01")
builds = travis.builds
puts "Number of builds: #{builds.length}"
puts "First build:      #{builds.first['html_url']} (#{builds.first['started_at'].rfc3339})"
puts "Last build:       #{builds.last['html_url']} (#{builds.last['started_at'].rfc3339})"

appveyor = Inq::Sources::CI::Appveyor.new("rubygems/rubygems", "2018-12-01", "2019-02-01")
builds = appveyor.builds
puts "Number of builds: #{builds.length}"
puts "First build:      #{builds.first['html_url']} (#{builds.first['started_at'].rfc3339})"
puts "Last build:       #{builds.last['html_url']} (#{builds.last['started_at'].rfc3339})"
