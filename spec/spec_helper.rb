# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "how_is"
require "how_is/text"
require "timecop"
require File.expand_path("./vcr_helper.rb", __dir__)

HowIs::Text.show_default_output = false

def env_vars_hidden?
  travis_pr = ENV["TRAVIS_PULL_REQUEST"]
  !travis_pr.nil? && (travis_pr != "false")
end

def config(repo)
  HowIs::Config.new
    .load_defaults
    .load({
      "repository" => repo,
      "cache" => { "type" => "marshal" }
    })
end

def cache(start_date, end_date)
  HowIs::Cacheable.new(config("how-is/how_is"), start_date, end_date)
end
