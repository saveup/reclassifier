# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'reclassifier/version'

Gem::Specification.new do |spec|
  spec.name          = "reclassifier"
  spec.version       = Reclassifier::VERSION
  spec.authors       = ["Ryan Oblak"]
  spec.email         = ["rroblak@gmail.com"]
  spec.description   = %q{Bayesian and Latent Semantic Indexing classification of text.}
  spec.summary       = %q{Bayesian and Latent Semantic Indexing classification of text.}
  spec.homepage      = "https://github.com/saveup/reclassifier"
  spec.license       = "LGPL"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'

  spec.add_dependency 'fast-stemmer'
  spec.add_dependency 'activesupport'
end
