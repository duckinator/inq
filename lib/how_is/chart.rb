class HowIs::Chart
  # Generates the gnuplot script in data/issues.plg.
  #
  # Some configuration is available. Font locations are path to a TTF or other
  # Gnuplot-readable font name.
  #
  # For example that could be '/Users/anne/Library/Fonts/InputMono-Medium.ttf'
  # or just 'Helvetica'.
  #
  # @param font_location [String] Font for the chart
  # @param font_size [Integer] Size of the chart text
  # @param label_font_location [String] Font for labels
  # @param label_font_size [Integer] Size of the label text
  #
  # @return void
  def self.gnuplot(font_location: 'Helvetica',
                   font_size: 16,
                   label_font_location: 'Helvetica',
                   label_font_size: 10,
                   chartsize: '500,500')
    cmd = %Q{
      gnuplot -e "labelfont='#{label_font_location},#{label_font_size}'" \
              -e "chartfont='#{font_location},#{font_size}'" \
              -e "chartsize='#{chartsize}'" \
              -c data/issues.plg
    }
    IO.popen(cmd, 'w')
  end

  def self.rotate(offset, filename)
    if Gem.win_platform?
      rotate_with_dotnet(filename, offset)
    else
      rotate_with_minimagick(filename, offset)
    end
  end

  def self.rotate_with_dotnet(filename, offset)
    ps_rotate_flip = {
      90  => 'Rotate90FlipNone',
      180 => 'Rotate180FlipNone',
      270 => 'Rotate270FlipNone',
      -90 => 'Rotate270FlipNone'
    }[offset]

    command = %Q{
      $path = "#{filename}"

      [Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms");
      $i = new-object System.Drawing.Bitmap $path

      $i.RotateFlip("#{ps_rotate_flip}")

      $i.Save($path,"png")

      exit
    }

    IO.popen(["powershell", "-Command", command], 'w') { |io| }
  end

  def self.rotate_with_minimagick(filename, offset)
    require 'mini_magick'
    image = MiniMagick::Image.new(filename) { |b| b.rotate offset.to_s }
    image.format 'png'
    image.write filename
  end
end
