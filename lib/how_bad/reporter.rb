require "csv"

class HowBad::Reporter
  def call(analysis, report:, **options)
    puts analysis # For testing plumbing.
  end
end
