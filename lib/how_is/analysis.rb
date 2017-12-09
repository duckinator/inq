require "how_is/analysis_helpers"
require "ostruct"

module HowIs
  class Analysis < OpenStruct
    # TODO: What the actual fuck am I even doing?
    include AnalysisHelpers
    extend AnalysisHelpers


  end
end
