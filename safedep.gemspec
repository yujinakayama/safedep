lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'safedep/version'

Gem::Specification.new do |spec|
  spec.name          = 'safedep'
  spec.version       = Safedep::Version.to_s
  spec.authors       = ['Yuji Nakayama']
  spec.email         = ['nkymyj@gmail.com']
  spec.summary       = 'Make your Gemfile safe by adding dependency version specifiers ' \
                       'automatically.'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/yujinakayama/safedep'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'bundler', '~> 1.7'
  spec.add_runtime_dependency 'gemologist', '>= 0.2.1', '< 1.0'
end
