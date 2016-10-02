module HowIs
  class JsonReport < BaseReport
    def format
      :json
    end

    def export(&block)
      to_json
    end

    def export_file(file, &block)
      File.open(file, 'w') do |f|
        f.write export
      end
    end
  end
end
