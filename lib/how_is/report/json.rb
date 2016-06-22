module HowIs
  class JsonReport < BaseReport
    def export(&block)
      to_json
    end

    def export!(file, &block)
      File.open(file, 'w') do |f|
        f.write export
      end
    end
  end
end
