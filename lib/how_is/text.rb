# frozen_string_literal: true

module HowIs
  # Helper class for printing test, but hiding it when e.g. running in CI.
  class Text
    class << self
      attr_accessor :show_default_output
      @show_default_output = true
    end

    def self.print(*args)
      print(*args) if HowIs::Text.show_default_output
    end

    def self.puts(*args)
      puts(*args) if HowIs::Text.show_default_output
    end
  end
end
