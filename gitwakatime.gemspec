# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gitwakatime/version'

Gem::Specification.new do |s|
  s.name          = 'gitwakatime'
  s.version       = GitWakaTime::VERSION
  s.authors       = ['Russell Osborne']
  s.email         = ['russosborn@gmail.com']
  s.summary       = 'A Tool that will compile git data with wakatime
                        data to establish time per commit'
  s.description   = 'A Tool that will compile git data with wakatime
                        data to establish time per commit '
  s.homepage      = ''
  s.license       = 'MIT'

  s.files = `git ls-files`.split($RS)
  s.test_files = s.files.grep(/^spec\//)
  s.executables = s.files.grep(/^bin\//) { |f| File.basename(f) }

  s.require_paths = ['lib']
  s.authors = ['Bozhidar Batsov', 'Jonas Arvidsson', 'Yuji Nakayama']
  s.description = <<-EOF
    Automatic Ruby code style checking tool.
    Aims to enforce the community-driven Ruby Style Guide.
  EOF

  s.add_runtime_dependency 'git', '>= 1.2.9.1'
  s.add_runtime_dependency 'wakatime', '>= 0.0.2'
  s.add_runtime_dependency 'logger', '>= 0'
  s.add_runtime_dependency 'thor', '>= 0'
  s.add_runtime_dependency 'chronic_duration', '>=0'
  s.add_runtime_dependency 'colorize'
  s.add_runtime_dependency 'activesupport'
  s.add_runtime_dependency 'sequel'
  s.add_runtime_dependency 'sqlite3'
  s.add_development_dependency('bundler', ['>= 0'])
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency('webmock', ['>= 0'])
  s.add_development_dependency('pry', ['>= 0'])
end
