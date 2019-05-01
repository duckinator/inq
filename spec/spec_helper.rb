# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "inq"
require "inq/text"
require "timecop"
require File.expand_path("./vcr_helper.rb", __dir__)

Inq::Text.show_default_output = false

def env_vars_hidden?
  travis_pr = ENV["TRAVIS_PULL_REQUEST"]
  !travis_pr.nil? && (travis_pr != "false")
end

def config(repo)
  Inq::Config.new
    .load_defaults
    .load({
      "repository" => repo,
      "cache" => { "type" => "marshal" }
    })
end

def cache(start_date, end_date)
  Inq::Cacheable.new(config("duckinator/inq"), start_date, end_date)
end

def load_test_env
  token = ENV["HOWIS_GITHUB_TOKEN"]
  username = ENV["HOWIS_GITHUB_USERNAME"]
  begin
    ENV["HOWIS_GITHUB_TOKEN"] = "blah"
    ENV["HOWIS_GITHUB_USERNAME"] = "who"
    yield
  ensure
    ENV["HOWIS_GITHUB_TOKEN"] = token
    ENV["HOWIS_GITHUB_USERNAME"] = username
  end
end
