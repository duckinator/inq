# frozen_string_literal: true

require 'cgi'
require 'how_is/report/base_report'

class HowIs
  class HtmlReport < BaseReport
    def format
      :html
    end

    def title(_text)
      @title = _text
      @r += "\n<h1>#{_text}</h1>\n"
    end

    def header(_text)
      @r += "\n<h2>#{_text}</h2>\n"
    end

    def link(_text, url)
      %Q[<a href="#{url}">#{_text}</a>]
    end

    def text(_text)
      @r += "<p>#{_text}</p>\n"
    end

    def unordered_list(arr)
      @r += "\n<ul>\n"
      arr.each do |item|
        @r += "  <li>#{item}</li>\n"
      end
      @r += "</ul>\n\n"
    end

    def horizontal_bar_graph(data)
      if data.length == 1 && data[0][0] == "(No label)"
        text "There are no open issues to graph."
        return
      end

      biggest = data.map { |x| x[1] }.max
      get_percentage = ->(number_of_issues) { number_of_issues * 100 / biggest }

      longest_label_length = data.map(&:first).map(&:length).max
      label_width = "#{longest_label_length}ch"

      @r += "<table class=\"horizontal-bar-graph\">\n"
      data.each do |row|
        percentage = get_percentage.call(row[1])

        if row[2]
          label_text = link(row[0], row[2])
        else
          label_text = row[0]
        end

        @r += <<-EOF
  <tr>
    <td style="width: #{label_width}">#{label_text}</td>
    <td><span class="fill" style="width: #{percentage}%">#{row[1]}</span></td>
  </tr>

        EOF
      end
      @r += "</table>\n"
    end

    def export
      @r = ''
      generate_report_text!
    end

    def export_file(file)
      report = export

      File.open(file, 'w') do |f|
        f.puts <<~EOF
          <!DOCTYPE html>
          <html>
          <head>
            <title>#{@title}</title>
            <style>
            body { font: sans-serif; }
            main {
              max-width: 600px;
              max-width: 72ch;
              margin: auto;
            }

            .horizontal-bar-graph {
              position: relative;
              width: 100%;
            }
            .horizontal-bar-graph .fill {
              display: inline-block;
              background: #CCC;
            }
            </style>
          </head>
          <body>
            <main>
            #{report}
            </main>
          </body>
          </html>
        EOF
      end
    end
  end
end
