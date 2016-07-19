require 'tessellator/fetcher'

module HowIs
  # This entire class is a monstrous hack, because GitHub doesn't provide a good
  # API for Pulse.
  class Pulse
    def initialize(repository)
      @repository = repository
      @pulse_page_source = fetch_pulse!(repository)
    end

    def text_summary
      raise NotImplementedError
    end

    def html_summary
      @pulse_page_source
        .split('<div class="section diffstat-summary">').last
        .split('').first
        .gsub('<a href="/', '<a href="https://github.com/')
        .strip
    end

  private
    def fetch_pulse!(repository, period='monthly')
      Tessellator::Fetcher.new.call('get', "https://github.com/#{repository}/pulse/#{period}")
    end
  end
end
