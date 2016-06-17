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
      filename_base = "./issues-per-label"
      dat_file = filename_base + '.dat'
      png_file = filename_base + '.png'

      File.open(dat_file, 'w') do |f|
        data.each_with_index do |(label, n), i|
          f.puts "#{i}\t#{n}\t\"#{label}\""
        end
      end

      Chart.gnuplot(label_font_size: 10,
                    font_size: 16,
                    data_file: dat_file,
                    png_file: png_file)
     Chart.rotate(90, png_file)

      pdf.image png_file
    end

    def text(_text)
      pdf.text _text
    end

    # Prawn (afaict) doesn't let you export to a binary blob.
    # So export to a file, then read the file.
    def export(&block)
      # TODO: Use actual temporary file.
      export!('temp.pdf', &block)

      open('temp.pdf').read
    end

    def export!(file, &block)
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
