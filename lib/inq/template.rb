# frozen_string_literal: true

require "inq/version"
require "okay/template"

module Inq
  # Provides basic templating functionality.
  Template = Okay::Template.new(File.expand_path("./templates/", __dir__))
end
