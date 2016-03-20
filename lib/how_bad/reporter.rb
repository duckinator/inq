require "contracts"
require "csv"

module HowBad
  class Reporter
    include Contracts::Core

    # TODO: Determine up return value.
    Contract Analysis, String => C::Any
    def call(analysis, report_file)
      puts analysis # For testing plumbing.
    end
  end
end
