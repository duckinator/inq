module HowIs
  class HtmlReport < BaseReport
    def export!(&block)
      raise NotImplementedError
    end
  end
end
