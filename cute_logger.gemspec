# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cute_logger/version'

Gem::Specification.new do |spec|
  spec.name          = 'cute_logger'
  spec.version       = CuteLogger::VERSION
  spec.authors       = ['Jorge Del Rio', 'Gilberto Vargas']
  spec.email         = ['jdelrios@gmail.com', 'tachoguitar@gmail.com']

  spec.summary       = 'This gem provides accesible methods for doing the ' \
                       'application logging in a simple manner'
  spec.description   = 'Cute Logger provides globally accesible methods to do' \
                       ' the logging. It also provides a log parser command f' \
                       ' or easy view during development. The gem includes me' \
                       ' chanisms for log rotation, improved exception loggin' \
                       'g and nice formatted log viewing among many other fea' \
                       'tures and best practices.'
  spec.homepage      = 'https://github.com/newint33h/cute_logger'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'awesome_print',  '~> 1'
  spec.add_runtime_dependency 'colorize',       '~> 0.8.1'
  spec.add_runtime_dependency 'utf8_converter', '~> 0.1'

  spec.add_development_dependency 'bundler',  '~> 1.10'
  spec.add_development_dependency 'rake',     '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5'
end
