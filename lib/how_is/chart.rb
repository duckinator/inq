class HowIs::Chart
  def self.gnuplot(commands)
    IO.popen("gnuplot", "w") {|io| io.puts commands}
  end

  def self.rotate(offset, filename)
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

    IO.popen(["powershell", "-Command", command], 'w') { |io|
    }
    $stderr.puts "Rotated image #{offset} degrees."
  end
end
