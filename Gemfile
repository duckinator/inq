source 'https://rubygems.org'

# Specify your gem's dependencies in how_is.gemspec
gemspec

# Everything says to put it here. It feels like it should go in the gemspec?
# SOMEBODY WHO KNOWS WHAT THEY'RE DOING PLEASE LET ME KNOW WHAT TO DO HERE.
group :test, :development do
  # Matches version used by Hound, even though there's newer releases.
  # https://github.com/houndci/linters/blob/master/Gemfile.lock
  gem 'rubocop', '~> 0.46.0', require: false
end
