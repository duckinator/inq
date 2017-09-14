module Warning
  # Where the codebase we're checking is located.
  CODEBASE_LOCATION = File.expand_path('../', __dir__)

  # .bundler/ is where Bundler dependencies are on most systems.
  BUNDLER_DIR_LOCATION = File.expand_path('.bundle', CODEBASE_LOCATION)

  # vendor/ is where Bundler dependencies are located on Travis CI.
  VENDOR_DIR_LOCATION = File.expand_path('vendor', CODEBASE_LOCATION)

  # Directories we want to ignore because they aren't part of the codebase
  # we're checking.
  IGNORED_DIRS = [
    BUNDLER_DIR_LOCATION,
    VENDOR_DIR_LOCATION,
  ]

  @@dependency_warnings = []
  @@codebase_warnings = []

  # Override Warning.warn(), so warnings from -w and -W are only printed
  # for things in how_is' codebase.
  def self.warn(msg)
    path = File.realpath(caller_locations.first.path)

    # Only print warnings for files in how_is' codebase.
    if path.start_with?(CODEBASE_LOCATION) && IGNORED_DIRS.none? { |dir| path.start_with?(dir) }
      @@codebase_warnings << msg
      super(msg)
    else
      @@dependency_warnings << msg
    end
  end

  def codebase_warnings
    @@codebase_warnings
  end

  def dependency_warnings
    @@dependency_warnings
  end

  def has_warnings?
    @@codebase_warnings.length > 0 || @@dependency_warnings.length > 0
  end
end

at_exit {
  if Warning.has_warnings?
    puts "=== Warnings ==="
    puts "#{Warning.codebase_warnings.length} warnings in how_is."
    puts "#{Warning.dependency_warnings.length} warnings in how_is' dependencies."
    puts "================"
  else
    puts "No warnings found in the codebase."
  end
}
