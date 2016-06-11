module HowIs
  class JsonReport < BaseReport
    def export!(&block)
      File.open(file, 'w') do |f|
        f.write to_json
      end
    end
  end
end
