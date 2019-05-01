# frozen_string_literal: true

require "spec_helper"
require "inq"
require "inq/config"
require "json"

describe Inq::Config do
  context "#load" do
    it "normalizes configs correctly" do
      hash1 = {
        'a' => '1',
        'b' => ['b1'],
      }
      hash2 = {
        'c' => '2',
        'b' => ['b2'],
      }
      hash3 = {
        'a' => '-1',
        'b' => ['b3'],
      }

      config = subject.load(hash1, hash2, hash3)
      expect(config).to eq({
        'a' => '-1',
        'b' => ['b1', 'b2', 'b3'],
        'c' => '2',
      })
    end
  end
end
