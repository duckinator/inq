#!/usr/bin/env ruby

require "bundler/setup" # to avoid having to do `bundle exec ...`
require "how_is/sources/ci/travis"
require "how_is/sources/ci/appveyor"
require "pp"

travis = HowIs::Sources::CI::Travis.new("rubygems/rubygems", "2018-04-01", "2018-04-30")
builds = travis.builds
puts "Number of builds: #{builds.length}"
puts "First build:      #{builds.first['html_url']} (#{builds.first['started_at'].rfc3339})"
puts "Last build:       #{builds.last['html_url']} (#{builds.last['started_at'].rfc3339})"

appveyor = HowIs::Sources::CI::Appveyor.new("rubygems/rubygems", "2018-01-01", "2018-04-30")
builds = appveyor.builds
pp builds
pp builds.length
#puts "Number of builds: #{builds.length}"
#puts "First build:      #{builds.first['html_url']} (#{builds.first['started_at'].rfc3339})"
#puts "Last build:       #{builds.last['html_url']} (#{builds.last['started_at'].rfc3339})"
