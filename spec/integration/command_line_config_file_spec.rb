require 'spec_helper'
require 'open3'

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

          Open3.popen3('bundle exec how_is --config ../data/integration/how_is.yml') do |stdin, stdout, stderr, wait_thr|
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
end
