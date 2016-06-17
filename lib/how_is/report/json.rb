module HowIs
  class JsonReport < BaseReport
    alias_method :export, :to_json

    def export!(&block)
      File.open(file, 'w') do |f|
        f.write export
      end
    end
  end
end
