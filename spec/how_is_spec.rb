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

describe HowIs do
  context 'with a config file' do
    it 'generates valid report files' do
      Dir.mktmpdir {|dir|
        Dir.chdir(dir) {
         VCR.use_cassette("how_is-with-config-file") do
            expect {
              HowIs::CLI.new.from_config_file(HOW_IS_CONFIG_FILE)
            }.to_not output.to_stderr
          end

          html_report = File.open('report.html').read
          json_report = File.open('report.json').read

          expect(html_report).to include(JEKYLL_HEADER)
        }
      }
    end
  end

  context 'HTML report for how-is/example-repository' do
    it 'generates a valid report' do
      expected = File.open(HOW_IS_EXAMPLE_REPOSITORY_HTML_REPORT).read.chomp
      actual = nil

      options = {
        repository: 'how-is/example-repository',
        format: 'html'
      }

      VCR.use_cassette("how_is-example-repository") do
        expect {
          actual = HowIs.generate_report(**options)
        }.to_not output.to_stderr
      end

      expect(expected).to eq(actual)
    end
  end

  context 'JSON report for how-is/example-repository' do
    it 'generates a valid report file' do
      expected = File.open(HOW_IS_EXAMPLE_REPOSITORY_JSON_REPORT).read.chomp
      actual = nil

      options = {
        repository: 'how-is/example-repository',
        format: 'json',
      }
      VCR.use_cassette("how_is-example-repository") do
        expect {
          actual = HowIs.generate_report(**options)
        }.to_not output.to_stderr
      end

      expect(expected).to eq(actual)
    end
  end
end
