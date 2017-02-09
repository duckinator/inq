require 'how_is/report/base_report'

class HowIs
  class JsonReport < BaseReport
    def format
      :json
    end

    def export
      to_json
    end

    def export_file(file)
      File.open(file, 'w') do |f|
        f.write export
      end
    end
  end
end
