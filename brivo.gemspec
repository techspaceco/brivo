# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'brivo/version'

Gem::Specification.new do |spec|
  spec.name          = "brivo"
  spec.version       = Brivo::VERSION
  spec.authors       = ["Adam Rainsby"]
  spec.email         = ["adamrainsby@live.co.uk"]

  spec.summary       = %q{Brivo API wrapper.}
  spec.homepage      = "https://github.com/techspaceco/brivo"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "webmock"
end
