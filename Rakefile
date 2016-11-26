require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'timecop'
require 'vcr'
require 'how_is'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

class HelperFunctions
  def self.freeze_time(&block)
    date = DateTime.parse('2016-11-01').new_offset(0)
    Timecop.freeze(date) do
      yield
    end
  end

  def self.generate_report(format)
    freeze_time do
      report = nil

      options = {
        repository: 'how-is/example-repository',
        format: format,
      }

      VCR.use_cassette("how_is-example-repository") do
        report = HowIs.generate_report(**options)
      end

      filename = File.expand_path("spec/data/example-repository-report.#{format}", __dir__)
      File.open(filename, 'w') do |f|
        f.puts report
        # Hack: Trailing newline is missing, otherwise.
        f.puts if format == 'html'
      end
    end
  end
end

namespace :generate do
  desc 'Generate example HTML report.'
  task :html do
    HelperFunctions.generate_report('html')
  end

  task :json do
    HelperFunctions.generate_report('json')
  end

  task :all => [:html, :json]
end
