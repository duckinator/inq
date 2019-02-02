require "how_is/version"
require "okay/template"

# :nodoc:
module HowIs
  Template = Okay::Template.new(File.expand_path("./templates/", __dir__))
end
