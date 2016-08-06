require 'feature_helper'
require 'open3'

HOW_IS_CONFIG_FILE_CONTENTS = <<-EOF
repository: rubygems/rubygems
reports:
  html:
    directory: .
    frontmatter:
      title: "%{repository} report"
      layout: default
    filename: "report.html"
  json:
    directory: json
    filename: "report.json"
EOF

JEKYLL_HEADER = <<-EOF
---
title: rubygems/rubygems report
layout: default
---
EOF

describe 'Command line' do
  context 'running how_is with a config file' do
    it 'generates valid report files' do
      Dir.mktmpdir {|dir|
        Dir.chdir(dir) {
          File.open('how_is.yml', 'w') {|f| f.puts HOW_IS_CONFIG_FILE_CONTENTS }

          data = {}

          Open3.popen3('bundle exec how_is --config') do |stdin, stdout, stderr, wait_thr|
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
