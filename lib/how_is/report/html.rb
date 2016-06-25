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
      @bar_graphs ||= 0
      @bar_graphs += 1

      @r += <<-EOF
<div id="bar-graph-#{@bar_graphs}"></div>
<script>
var data = [{
  type: 'bar',
  x: #{data.map(&:last).to_json},
  y: #{data.map(&:first).to_json},
  orientation: 'h'
}];

Plotly.newPlot("bar-graph-#{@bar_graphs}", data);
</script>
      EOF
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
  </style>

  <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
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
