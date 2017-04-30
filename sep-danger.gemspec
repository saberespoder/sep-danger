# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sep/danger/version'

Gem::Specification.new do |spec|
  spec.name          = "sep-danger"
  spec.version       = Sep::Danger::VERSION
  spec.authors       = ["SEP Geek Squad"]
  spec.email         = ["tech@saberespoder.com"]

  spec.summary       = %q{Danger.systems conventions for SEP projects.}
  spec.description   = %q{Packages a Dangerfile to be used with Danger for SEP projects.}
  spec.homepage      = "https://github.com/saberespoder/sep-danger"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'danger', '~> 4.2'
  spec.add_runtime_dependency 'danger-rubocop'
  spec.add_runtime_dependency 'danger-junit'
  spec.add_runtime_dependency 'danger-simplecov_json'
  spec.add_runtime_dependency 'danger-pronto'
  spec.add_runtime_dependency 'pronto'
  spec.add_runtime_dependency 'pronto-rubocop'
  spec.add_runtime_dependency 'pronto-haml'
  spec.add_runtime_dependency 'pronto-stylelint'
  spec.add_runtime_dependency 'pronto-rails_best_practices'

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
