require 'spec_helper'
require 'open3'

HOW_IS_CONFIG_FILE = File.expand_path('../data/integration/how_is.yml', __dir__)
HOW_IS_EXAMPLE_REPOSITORY_JSON_REPORT = File.expand_path('../data/example-repository-report.json', __dir__)
HOW_IS_EXAMPLE_REPOSITORY_HTML_REPORT = File.expand_path('../data/example-repository-report.html', __dir__)

JEKYLL_HEADER = <<-EOF
---
title: rubygems/rubygems report
layout: default
---
EOF

describe 'Command line', :integration do
  context 'running how_is with a config file' do
    it 'generates valid report files' do
      Dir.mktmpdir {|dir|
        Dir.chdir(dir) {
          data = {}

          Open3.popen3("bundle exec how_is --config #{HOW_IS_CONFIG_FILE}") do |stdin, stdout, stderr, wait_thr|
            wait_thr.join # Wait for command to finish executing.

            data[:stdout] = stdout.read
            data[:stderr] = stderr.read
          end

          expect(data[:stderr]).to be_empty

          html_report = File.open('report.html').read
          json_report = File.open('report.json').read

          expect(html_report).to include(JEKYLL_HEADER)
        }
      }
    end
  end

  context 'running `how_is how-is/example-repository`' do
    it 'generates a valid report file' do
      Dir.mktmpdir {|dir|
        Dir.chdir(dir) {
          data = {}

          Open3.popen3("bundle exec how_is how-is/example-repository") do |stdin, stdout, stderr, wait_thr|
            wait_thr.join # Wait for command to finish executing.

            data[:stdout] = stdout.read
            data[:stderr] = stderr.read
          end

          expect(data[:stderr]).to be_empty

          #expected = File.open(HOW_IS_EXAMPLE_REPOSITORY_HTML_REPORT).read.chomp
          #actual   = File.open('report.html').read.chomp
          #
          #expect(expected).to eq(actual)
        }
      }
    end
  end

  context 'running `how_is how-is/example-repository --report report.json`' do
    it 'generates a valid report file' do
      Dir.mktmpdir {|dir|
        Dir.chdir(dir) {
          data = {}

          Open3.popen3("bundle exec how_is how-is/example-repository --report report.json") do |stdin, stdout, stderr, wait_thr|
            wait_thr.join # Wait for command to finish executing.

            data[:stdout] = stdout.read
            data[:stderr] = stderr.read
          end

          expect(data[:stderr]).to be_empty

          expected = File.open(HOW_IS_EXAMPLE_REPOSITORY_JSON_REPORT).read.chomp
          actual   = File.open('report.json').read.chomp

          expect(expected).to eq(actual)
        }
      }
    end
  end
end
