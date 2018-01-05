#!/usr/bin/env ruby

$: << "./lib"

require "how_is"
require "how_is/sources/github"
require "pry"

#graphql = HowIs::Sources::Github.graphql
graphql = HowIs::Sources::Github::Issues.new("how-is/how_is", "2017-12-30").send(:fetch_graphql!)
binding.pry



