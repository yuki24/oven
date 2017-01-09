# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'oven/version'

Gem::Specification.new do |spec|
  spec.name          = "oven"
  spec.version       = Oven::VERSION
  spec.authors       = ["Yuki Nishijima"]
  spec.email         = ["mail@yukinishijima.net"]
  spec.summary       = %q{Static API client generator}
  spec.description   = %q{Oven generates a dependency-free HTTP client.}
  spec.homepage      = "https://github.com/yuki24/oven"
  spec.license       = "MIT"
  spec.files         = `git ls-files -z`.split("\x0").reject {|f| f.match(%r{^(test)/}) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.2.0'

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "webmock"
end
