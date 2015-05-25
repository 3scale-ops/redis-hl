# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'redis-hl/version'

Gem::Specification.new do |spec|
  spec.name          = 'redis-hl'
  spec.version       = RedisHL::VERSION
  spec.authors       = ["Alejandro Martinez Ruiz"]
  spec.email         = ['alex@flawedcode.org']
  spec.description   = %q{A high-level wrapper over the Redis client for Ruby}
  spec.summary       = %q{A high-level wrapper over the Redis client for Ruby}
  spec.homepage      = "http://github.com/unleashed/redis-hl"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.1.0'

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.2"
end
