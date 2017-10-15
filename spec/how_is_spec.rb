# frozen_string_literal: true

require "spec_helper"
require "open3"
require "timecop"
require "yaml"

HOW_IS_CONFIG_FILE = File.expand_path("./data/how_is.yml", __dir__)

HOW_IS_EXAMPLE_REPOSITORY_JSON_REPORT = File.expand_path("./data/how-is-example-repository-report.json", __dir__)
HOW_IS_EXAMPLE_REPOSITORY_HTML_REPORT = File.expand_path("./data/how-is-example-repository-report.html", __dir__)

HOW_IS_EXAMPLE_EMPTY_REPOSITORY_HTML_REPORT =
  File.expand_path("./data/how-is-example-empty-repository-report.html", __dir__)

JEKYLL_HEADER =
  <<~EOF
    ---
    title: rubygems/rubygems report
    layout: default
    ---
  EOF

describe HowIs do
  before do
    # 2016-11-01 00:00:00 UTC.
    # See note in lib/how_is/report.rb about new_offset.
    # TODO: Stop pretending to always be in UTC.
    date = DateTime.parse("2016-11-01").new_offset(0)
    Timecop.freeze(date)
  end

  after do
    Timecop.return
  end

  it "from_json(json) works" do
    expected = File.open(HOW_IS_EXAMPLE_REPOSITORY_JSON_REPORT).read
    actual = HowIs.from_json(expected).to_json

    expect(expected.strip).to eq(actual.strip)
  end

  context "with a config" do
    it "generates valid report files" do
      Dir.mktmpdir { |dir|
        Dir.chdir(dir) {
          reports = nil

          VCR.use_cassette("how-is-with-config-file") do
            expect {
              reports = HowIs.from_config(YAML.load_file(HOW_IS_CONFIG_FILE), "2017-08-01")
            }.to_not output.to_stderr
          end

          html_report = reports["./report.html"]
          # TODO: Verify that JSON report is correct.
          # json_report = reports['./report.json']

          expect(html_report).to include(JEKYLL_HEADER)
        }
      }
    end
  end

  context "HTML report for how-is/example-repository" do
    it "generates a valid report" do
      expected = File.open(HOW_IS_EXAMPLE_REPOSITORY_HTML_REPORT).read.chomp
      actual = nil

      VCR.use_cassette("how-is-example-repository") do
        expect {
          actual = HowIs.new("how-is/example-repository", start_date: "2016-11-01").to_html
        }.to_not output.to_stderr
      end

      expect(expected).to eq(actual)
    end
  end

  context "JSON report for how-is/example-repository" do
    it "generates a valid report file" do
      expected = File.open(HOW_IS_EXAMPLE_REPOSITORY_JSON_REPORT).read.chomp
      actual = nil

      VCR.use_cassette("how-is-example-repository") do
        expect {
          actual = HowIs.new("how-is/example-repository", start_date: "2016-11-01").to_json
        }.to_not output.to_stderr
      end

      expect(expected).to eq(actual)
    end
  end

  context "HTML report for repository with no PRs or issues" do
    it "generates a valid report file" do
      expected = File.open(HOW_IS_EXAMPLE_EMPTY_REPOSITORY_HTML_REPORT).read.chomp
      actual = nil

      VCR.use_cassette("how-is-example-empty-repository") do
        expect {
          actual = HowIs.new("how-is/example-empty-repository", start_date: "2016-11-01").to_html
        }.to_not output.to_stderr
      end

      expect(expected).to eq(actual)
    end
  end

  context "#generate_frontmatter" do
    it "works with frontmatter parameter using String keys, report_data using String keys" do
      actual = nil
      expected = nil

      VCR.use_cassette("how-is-example-repository") do
        actual = HowIs.send(:generate_frontmatter, {"foo" => "bar %{baz}"}, {"baz" => "asdf"})
        expected = "---\nfoo: bar asdf\n"
      end

      expect(actual).to eq(expected)
    end

    it "works with frontmatter parameter using Symbol keys, report_data using Symbol keys" do
      actual = nil
      expected = nil

      VCR.use_cassette("how-is-example-repository") do
        actual = HowIs.send(:generate_frontmatter, {:foo => "bar %{baz}"}, {:baz => "asdf"})
        expected = "---\nfoo: bar asdf\n"
      end

      expect(actual).to eq(expected)
    end
  end

  context "#from_config" do
    let(:config) {
      file = File.expand_path("./data/how_is/cli_spec/how_is.yml", __dir__)
      YAML.load_file(file)
    }

    let(:issues) { JSON.parse(open(File.expand_path("./data/issues.json", __dir__)).read) }
    let(:pulls) { JSON.parse(open(File.expand_path("./data/pulls.json", __dir__)).read) }

    let(:github) {
      instance_double(
        "GitHub",
        issues: instance_double("GitHub::Issues", list: issues),
        pulls: instance_double("GitHub::Pulls", list: pulls)
      )
    }

    let(:report_class) {
      Class.new {
        def self.export(_analysis, _format)
          "[report]"
        end
      }
    }

    it "generates a report, with correct frontmatter" do
      reports = nil

      VCR.use_cassette("how-is-from-config-frontmatter") do
        reports = HowIs.from_config(config, github: github, report_class: report_class)
      end

      actual_html = reports["output/report.html"]
      actual_json = reports["output/report.json"]

      expected_html = <<~EOF
        ---
        title: rubygems/rubygems report
        layout: default
        ---

        [report]
      EOF
      # Not valid JSON, because report_class.export() is the same static string
      # regardless of format.
      expected_json = "[report]\n"

      expect(actual_html).to eq(expected_html)
      expect(actual_json).to eq(expected_json)
    end
  end
end
