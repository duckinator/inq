require 'spec_helper'
require 'how_is/cli'

describe HowIs::CLI do
  subject { HowIs::CLI.new }

  context '.generate_frontmatter' do
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
end
