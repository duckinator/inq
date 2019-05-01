# frozen_string_literal: true

module Inq
  ##
  # Helper class for printing text, but hiding it when e.g. running in CI.
  class Text
    def self.show_default_output
      @show_default_output = true unless
        instance_variable_defined?(:"@show_default_output")

      @show_default_output
    end

    def self.show_default_output=(val)
      @show_default_output = val
    end

    def self.print(*args)
      Kernel.print(*args) if Inq::Text.show_default_output
    end

    def self.puts(*args)
      Kernel.puts(*args) if Inq::Text.show_default_output
    end
  end
end
