class HowIs::Chart
  def self.gnuplot(commands)
    IO.popen("gnuplot", "w") {|io| io.puts commands}
  end

  def self.rotate(offset, filename)
    if on_windows?
      rotate_with_dotnet(filename, offset)
    else
      rotate_with_minimagick(filename, offset)
    end
    $stderr.puts "Rotated image #{offset} degrees."
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

  def self.on_windows?
    %w(mswin32 mingw32).include? Gem::Platform.local.os
  end
end
