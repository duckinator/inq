require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'timecop'
require './spec/vcr_helper.rb'
require 'how_is'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

class HelperFunctions
  def self.freeze_time(&_block)
    date = DateTime.parse('2016-11-01').new_offset(0)
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

      cassette = repository.tr('/', '-')
      VCR.use_cassette(cassette) do
        report = HowIs.generate_report(**options)
      end

      filename = "#{cassette}-report.#{format}"
      path = File.expand_path("spec/data/#{filename}", __dir__)
      File.open(path, 'w') do |f|
        f.puts report
        # HACK: Trailing newline is missing, otherwise.
        f.puts if format == 'html'
      end
    end
  end
end

namespace :generate_reports do
  desc 'Generate example HTML reports.'
  task :html do
    %w[
      how-is/example-repository
      how-is/example-empty-repository
    ].each do |repo|
      HelperFunctions.generate_report(repo, 'html')
    end
  end

  desc 'Generate example JSON reports.'
  task :json do
    HelperFunctions.generate_report('how-is/example-repository', 'json')
  end

  task :all => [:html, :json]
end
