lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cute_logger/version'

Gem::Specification.new do |spec|
  spec.name          = 'cute_logger'
  spec.version       = CuteLogger::VERSION
  spec.authors       = ['Jorge Del Rio']
  spec.email         = ['jdelrios@gmail.com']

  spec.summary       = 'This gem provides accesible methods for doing the application logging in a simple manner'
  spec.description   = 'Cute Logger provides globally accesible methods to do the logging. It also provides a' +
                       ' log parser command for easy view during development. The gem includes mechanisms for' +
                       ' log rotation, improved exception logging and nice formatted log viewing among many' +
                       ' other features and best practices.'
  spec.homepage      = 'https://github.com/newint33h/cute_logger'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'amazing_print', '~> 1.4'
  spec.add_runtime_dependency 'colorize', '~> 0.8'
  spec.add_runtime_dependency 'utf8_converter', '~> 0.1'

  spec.add_development_dependency 'bundler', '~> 2.3'
  spec.add_development_dependency 'minitest', '~> 5'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'simplecov', '~> 0.21'
end
