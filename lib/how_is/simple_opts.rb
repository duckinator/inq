# frozen_string_literal: true

require "optparse"

# A simple OptionParser wrapper.
class SimpleOpts < OptionParser
  def initialize(*args, defaults: nil)
    super(*args)
    @hi_options = defaults || {}
  end

  # simple(..., :a)
  # simple(..., :b)
  #   ==
  # options = {}
  # on(...) { |val| options[:a] = val }
  # on(...) { |val| options[:b] = val }
  def simple(*args)
    key = args.pop
    on(*args) { |*x| @hi_options[key] = x[0] }
  end

  def parse(args)
    parse!(args.dup)
    @hi_options
  end
end
