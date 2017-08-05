# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "timecop"
require "./spec/vcr_helper.rb"
require "how_is"

RSpec::Core::RakeTask.new(:spec) do |t|
  # Warning.warn() was added in Ruby 2.4.0, so don't use -w on older versions.
  t.ruby_opts = "-w -r./spec/capture_warnings.rb" if RUBY_VERSION >= "2.4.0"
end

task :default => :spec

task :generate_changelog do
  sh "github_changelog_generator"
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
    %w[
      how-is/example-repository
      how-is/example-empty-repository
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

desc "List new committers. Lists committers with no earlier commits then "\
     "given since_date (as %Y-%m-%d). Defaults to first of current month."
task :new_committers, [:user, :repo, :since_date] => [] do |_t, args|
  require 'how_is/contributions'
  user = args[:user] || "how-is"
  repo = args[:repo] || "how_is"
  since_date = args[:since_date] || Time.now.strftime('%Y-%m-01')

  puts "New committers:"
  puts Contributions.new(github: Github.new(auto_pagination: true),
                                    since_date: since_date,
                                    user: user,
                                    repo: repo
                                    ).new_committers
end
