# frozen_string_literal: true

require "spec_helper"

INQ_EXE = File.expand_path("../../exe/inq", __dir__)

describe "Integration Tests" do
  context "--help and -h flags" do
    it "outputs usage information" do
      ["--help", "-h"].each do |flag|
        stub_const("ARGV", [flag])

        expect {
          load INQ_EXE
        }.to output(/Usage: inq /).to_stdout
      end
    end
  end

  context "--version and -v flags" do
    it "outputs the version number" do
      ["--version", "-v"].each do |flag|
        stub_const("ARGV", [flag])

        expect {
          load INQ_EXE
        }.to output("#{Inq::VERSION}\n").to_stdout
      end
    end
  end
end
