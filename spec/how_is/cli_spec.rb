require 'spec_helper'
require 'how_is/cli'

describe HowIs::CLI do
  subject { HowIs::CLI.new }

  context '#generate_frontmatter' do
    it 'works with frontmatter parameter using String keys, report_data using String keys' do
      actual = subject.generate_frontmatter({'foo' => "bar %{baz}"}, {'baz' => "asdf"})
      expected = "---\nfoo: bar asdf\n"

      expect(actual).to eq(expected)
    end

    it 'works with frontmatter parameter using Symbol keys, report_data using Symbol keys' do
      actual = subject.generate_frontmatter({:foo => "bar %{baz}"}, {:baz => "asdf"})
      expected = "---\nfoo: bar asdf\n"

      expect(actual).to eq(expected)
    end
  end

  # NOTE: Only testing #from_config_file, not #from_config, because if
  #       #from_config_file works, that implies #from_config works.
  context '#from_config_file' do
    let(:config_file) {
      File.expand_path('../data/how_is/cli_spec/how_is.yml', __dir__)
    }

    let(:issues) { JSON.parse(open(File.expand_path('../data/issues.json', __dir__)).read) }
    let(:pulls) { JSON.parse(open(File.expand_path('../data/pulls.json', __dir__)).read) }

    let(:github) {
      instance_double('GitHub',
        issues: instance_double('GitHub::Issues', list: issues),
        pulls: instance_double('GitHub::Pulls', list: pulls)
      )
    }

    let(:report_class) {
      Class.new {
        def self.export(analysis, format)
          "[report]"
        end
      }
    }

    it 'generates a report, with correct frontmatter' do
      request = subject.from_config_file(config_file, github: github, report_class: report_class)
      actual = open('../data/how_is/cli_spec/output/report.html').read

      expected = <<-EOF
---
title: "rubygems/rubygems report"
layout: default
---

[report]
      EOF

      expect(actual).to eq(expected)
    end
  end
end
