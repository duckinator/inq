# frozen_string_literal: true

require "how_is/warning_helpers"
require "pathname"

module HowIs
  ##
  # Handles various templating requirements for HowIs.
  class Template
    include WarningHelpers

    def initialize(filename)
      dir = File.expand_path("./templates/", __dir__)
      filename = "#{filename}.html_template"
      @file = Pathname(dir).join(filename)
    end

    def apply(data)
      silence_warnings { Kernel.format(@file.read, data) }
    end
  end
end
