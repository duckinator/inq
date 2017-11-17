# frozen_string_literal: true

require "tessellator/fetcher"

class HowIs
  # This entire class is a monstrous hack, because GitHub doesn't provide
  # a good API for Pulse.
  #
  # TODO: Use GitHub's Statistics API to replace this garbage.
  #   See https://github.com/how-is/how_is/issues/122
  class XPulse
    def initialize(repository)
      @repository = repository
      @pulse_page_response = fetch_pulse!(repository)
    end

    # Gets the HTML Pulse summary.
    def html_summary
      if stats_section?
        stats_html_fragment.gsub('<a href="/', '<a href="https://github.com/')
      else
        "There hasn't been any activity on #{@repository} in the last month."
      end
    end

    private

    HTML_SEPARATOR_FOR_STATS = '<div class="section diffstat-summary">'

    def stats_section?
      parts.count > 1
    end

    def parts
      @parts ||= @pulse_page_response.body.split(HTML_SEPARATOR_FOR_STATS)
    end

    def stats_html_fragment
      parts.last.split("</div>").first.strip
    end

    # Fetch Pulse page from GitHub for scraping.
    def fetch_pulse!(repository)
      Tessellator::Fetcher.new.call("get", "https://github.com/#{repository}/pulse/monthly")
    end
  end
end
