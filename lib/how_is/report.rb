# frozen_string_literal: true

module HowIs
  class Report
    def initialize(repository, end_date)
      @repository = repository
      @end_date = end_date
    end



    def to_html
      #...
    end

    def to_json
      #...
    end
  end
end
