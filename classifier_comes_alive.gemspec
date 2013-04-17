# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'classifier_comes_alive/version'

Gem::Specification.new do |spec|
  spec.name          = "classifier_comes_alive"
  spec.version       = ClassifierComesAlive::VERSION
  spec.authors       = ["Ryan Oblak"]
  spec.email         = ["rroblak@gmail.com"]
  spec.description   = %q{A general classifier module to allow Bayesian and other types of classifications.}
  spec.homepage      = "https://github.com/zenprogrammer/classifier_comes_alive"
  spec.license       = "LGPL"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
