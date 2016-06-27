module HowIs
  class HtmlReport < BaseReport
    def title(_text)
      @title = _text
      @r += "<h1>#{_text}</h1>"
    end

    def header(_text)
      @r += "<h2>#{_text}</h2>"
    end

    def horizontal_bar_graph(data)
      biggest = data.map(&:last).max
      get_percentage = ->(number_of_issues) { number_of_issues * 100 / biggest }

      longest_label_length = data.map(&:first).map(&:length).max
      label_width = "#{longest_label_length}ch"

      @r += '<table class="horizontal-bar-graph">'
      data.each do |row|
        percentage = get_percentage.(row[1])
        @r += <<-EOF
  <tr>
    <td style="width: #{label_width}">#{row[0]}</td>
    <td><span class="fill" style="width: #{percentage}%">#{row[1]}</span></td>
  </tr>
        EOF
      end
      @r += "</table>"
    end

    def text(_text)
      @r += "<p>#{_text}</p>"
    end

    def export(&block)
      @r = ''
      instance_exec(&block)
    end

    def export!(file, &block)
      report = export(&block)

      File.open(file, 'w') do |f|
        f.puts <<-EOF
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
