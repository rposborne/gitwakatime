# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gitwakatime/version'

Gem::Specification.new do |spec|
  spec.name          = "gitwakatime"
  spec.version       = GitWakaTime::VERSION
  spec.authors       = ["Russell Osborne"]
  spec.email         = ["russosborn@gmail.com"]
  spec.summary       = %q{A Tool that will compile git data with wakatime data to establish time per commit}
  spec.description   = %q{A Tool that will compile git data with wakatime data to establish time per commit }
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "git", ">= 0"
  spec.add_runtime_dependency "wakatime", ">= 0"
  spec.add_runtime_dependency "logger", ">= 0"
  spec.add_runtime_dependency "thor", ">= 0"
  spec.add_runtime_dependency "chronic_duration", ">=0"
  spec.add_runtime_dependency "colorize"
  spec.add_development_dependency("bundler", [">= 0"])
  spec.add_development_dependency "rake"
  spec.add_development_dependency "awesome_print"
end
