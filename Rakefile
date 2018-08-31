# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "timecop"
require "how_is"

RSpec::Core::RakeTask.new(:spec) do |t|
  # Warning.warn() was added in Ruby 2.4.0, so don't use -w on older versions.
  t.ruby_opts = "-w -r./spec/capture_warnings.rb" if RUBY_VERSION >= "2.4.0"
end

task :default => :spec

task :generate_changelog do
  sh "github_changelog_generator"
end

task :future_changelog do
  sh "github_changelog_generator --future-release v#{HowIs::VERSION}"
end

# Helper functions used later in the Rakefile.
class HelperFunctions
  def self.freeze_time(&_block)
    date = DateTime.parse("2016-11-01").new_offset(0)
    Timecop.freeze(date) do
      yield
    end
  end

  def self.generate_report(repository, format)
    require "./spec/vcr_helper.rb"

    freeze_time do
      report = nil

      options = {
        repository: repository,
        format: format,
      }

      cassette = repository.tr("/", "-")
      VCR.use_cassette(cassette) do
        report = HowIs.generate_report(**options)
      end

      filename = "#{cassette}-report.#{format}"
      path = File.expand_path("spec/data/#{filename}", __dir__)
      File.open(path, "w") do |f|
        f.puts report
        # HACK: Trailing newline is missing, otherwise.
        f.puts if format == "html"
      end
    end
  end
end

namespace :generate_reports do
  desc "Generate example HTML reports."
  task :html do
    [
      "how-is/example-repository",
      "how-is/example-empty-repository",
    ].each do |repo|
      HelperFunctions.generate_report(repo, "html")
    end
  end

  desc "Generate example JSON reports."
  task :json do
    HelperFunctions.generate_report("how-is/example-repository", "json")
  end

  task :all => [:html, :json]
end

desc "List new contributors. Lists committers with no earlier commits then "\
  "given start_date (as %Y-%m-%d). Defaults to first of current month."
task :new_contributors, [:user, :repo, :start_date] => [] do |_t, args|
  require "how_is/contributions"
  user = args[:user] || "how-is"
  repo = args[:repo] || "how_is"
  start_date = args[:start_date] || Time.now.strftime("%Y-%m-01")

  contributions = HowIs::Contributions.new(start_date: start_date,
                                           user: user,
                                           repo: repo)

  puts "New committers:"
  puts contributions.summary
  puts contributions.new_contributors
end

desc "Display duration of latest CI build. CI builds supported include Travis."
task :test_execution_time, [:user, :repo] => [] do |_t, args|
  require "how_is/builds"
  user = args[:user] || "how-is"
  repo = args[:repo] || "how_is"
  builds = HowIs::Builds.new(user: user, repo: repo)

  puts "Test execution information:"
  puts builds.summary
end
