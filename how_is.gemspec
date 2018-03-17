# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'how_is/version'

Gem::Specification.new do |spec|
  spec.name          = "how_is"
  spec.version       = HowIs::VERSION
  spec.authors       = ["Ellen Marie Dash"]
  spec.email         = ["me@duckie.co"]

  spec.summary       = %q{Quantify the health of a GitHub repository.}
  spec.homepage      = "https://github.com/how-is/how_is"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "github_api", "~> 0.18.1"
  spec.add_runtime_dependency "contracts", "~> 0.16.0"

  spec.add_runtime_dependency "okay", "~> 7.0.0"

  spec.add_runtime_dependency "json"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 12.3"
  spec.add_development_dependency "rspec", "~> 3.7"
  spec.add_development_dependency "timecop", "~> 0.9.1"
  spec.add_development_dependency "vcr", "~> 4.0"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "rubocop", "~> 0.49.1"
  spec.add_development_dependency "github_changelog_generator"
  spec.add_development_dependency "pry"
end
