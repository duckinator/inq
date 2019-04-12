# frozen_string_literal: true

require "how_is/version"
require "okay/template"

module HowIs
  # Provides basic templating functionality.
  Template = Okay::Template.new(File.expand_path("./templates/", __dir__))
end
