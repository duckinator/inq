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
      @r += "<p>horizontal_bar_graph not implemented.</p>"
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
        f.puts "\
<!DOCTYPE html>
<html>
<head>
  <title>#{@title}</title>
  <style>
  body { font: sans-serif;}
  main {
    max-width: 600px;
    max-width: 72ch;
    margin: auto;
  }
  </style>
</head>
<body>
  <main>
  #{report}
  </main>
</body>
</html>
"
      end
    end
  end
end
