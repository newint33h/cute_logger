# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cute_logger/version'

Gem::Specification.new do |spec|
  spec.name          = 'cute_logger'
  spec.version       = CuteLogger::VERSION
  spec.authors       = ['Jorge Del Rio']
  spec.email         = ['jdelrios@gmail.com']

  spec.summary       = 'Gem to simplify and centralize the logging process'
  spec.description   = 'This gem provides methods to log events to an unique place'
  spec.homepage      = 'https://github.com/newint33h/cute_logger'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'awesome_print', '~> 1'
  spec.add_runtime_dependency 'utf8_converter', '~> 0.1'

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5'
end
