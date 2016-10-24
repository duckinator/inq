require 'spec_helper'

HOW_IS_EXE = File.expand_path('../../exe/how_is', __dir__)

describe 'Integration Tests' do
  context '--help and -h flags' do
    it 'outputs usage information' do
      %w[--help -h].each do |flag|
        stub_const("ARGV", [flag])

        expect {
          load HOW_IS_EXE
        }.to output(/Usage: how_is /).to_stdout
      end
    end
  end

  context '--version and -v flags' do
    it 'outputs the version number' do
      %w[--version -v].each do |flag|
        stub_const("ARGV", [flag])

        expect {
          load HOW_IS_EXE
        }.to output("#{HowIs::VERSION}\n").to_stdout
      end
    end
  end
end
