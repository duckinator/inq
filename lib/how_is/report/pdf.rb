module HowIs
  class PdfReport < BaseReport
    attr_accessor :pdf

    def title(_text)
      pdf.pad_bottom(10) {
        pdf.text(_text, size: 25)
      }
    end

    def header(_text)
      pdf.pad_top(15) {
        pdf.pad_bottom(3) {
          pdf.text _text, size: 20
        }
      }
    end

    def horizontal_bar_graph(data)
      filename_base = "horizontal-bar-graph-#{Time.now.to_i}"
      dat_file = filename_base + '.dat'
      png_file = filename_base + '.png'

      File.open(dat_file, 'w') do |f|
        data.each_with_index do |(label, n), i|
          f.puts "#{i}\t#{n}\t#{label}"
        end
      end

      Chart.gnuplot(%Q{
        set terminal png size 500x500
        set output 'issues-per-label.png'
        set nokey
        unset border
        unset xtics

        plot '#{dat_file}' using 1:(-1):3 with labels rotate right, \
             '#{dat_file}' using 1:2 with boxes
        })
      Chart.rotate(90, png_file)

      image png_file
    end

    def text(_text)
      pdf.text _text
    end

    def export!(&block)
      _self = self

      Prawn::Document.generate(file) do |pdf|
        _self.pdf = pdf

        pdf.font("Helvetica")

        pdf.span(450, position: :center) do
          _self.instance_eval(&block)
        end
      end
    end
  end
end
