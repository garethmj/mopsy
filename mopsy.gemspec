# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "mopsy/version"

Gem::Specification.new do |spec|
  spec.name    = 'mopsy'
  spec.version = Mopsy::VERSION
  spec.authors = ['Gareth Jones']
  spec.email   = ['garethmichaeljones@gmail.com']

  spec.summary     = %q( Yet another job/RPC framework for Ruby and RabbitMQ )
  spec.description = %q( Yet another job/RPC framework for Ruby and RabbitMQ )
  spec.homepage    = 'https://github.com/garethmj/mopsy.git'
  spec.license     = 'MIT'

  spec.files         = `git ls-files`.split($/).reject { |f| f == 'Gemfile.lock' }
  spec.executables   = spec.files.grep(/^bin/).map { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(/^(test|spec|features)\//)
  spec.require_paths = ['lib']

  spec.add_dependency 'bunny', '~> 2.7'
  spec.add_dependency 'concurrent-ruby', '~> 1.0'
  spec.add_dependency 'serverengine', '~> 2.0', '>= 2.0.5'
  spec.add_dependency 'thor'

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
