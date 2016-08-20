require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

namespace :test do
  task :units => :spec

  desc 'Run integration tests tag'
  RSpec::Core::RakeTask.new('integration') do |task|
    task.pattern = './spec/**/*_spec.rb'
    task.rspec_opts = '--tag integration'
  end

  desc 'Run slow tests tag'
  RSpec::Core::RakeTask.new('integration') do |task|
    task.pattern = './spec/**/*_spec.rb'
    task.rspec_opts = '--tag slow'
  end


  desc 'Run all tests regardless of tags'
  RSpec::Core::RakeTask.new('all') do |task|
    task.pattern = './spec/**/*_spec.rb'
    # Load the tagless options file
    task.rspec_opts = '-O .rspec-ignore-tags'
  end
end
