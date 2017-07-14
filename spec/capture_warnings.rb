module Warning
  CODEBASE_LOCATION = File.expand_path('../', __dir__)
  BUNDLER_DIR_LOCATION = File.expand_path('.bundle', CODEBASE_LOCATION)

  @@other_warnings = []
  @@howis_warnings = []

  # Override Warning.warn(), so warnings from -w and -W are only printed
  # for things in how_is' codebase.
  def self.warn(msg)
    path = File.realpath(caller_locations.first.path)

    # Only print warnings for files in how_is' codebase.
    if path.start_with?(CODEBASE_LOCATION) && !path.start_with?(BUNDLER_DIR_LOCATION)
      @@howis_warnings << msg
      super(msg)
    else
      @@other_warnings << msg
    end
  end

  def howis_warnings
    @@howis_warnings
  end

  def other_warnings
    @@other_warnings
  end

  def self.has_warnings?
    @@howis_warnings.length > 0 || @@other_warnings.length > 0
  end
end

at_exit {
  if Warning.has_warnings?
    puts "=== Warnings ==="
    puts "#{Warning.howis_warnings.length} warnings in how_is."
    puts "#{Warning.other_warnings.length} warnings in how_is' dependencies."
    puts "================"
  else
    puts "No warnings found in the codebase."
  end
}
