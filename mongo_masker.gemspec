Gem::Specification.new do |s|
  s.name        = 'mongo_masker'
  s.version     = '1.0.2'
  s.date        = '2020-01-23'
  s.summary     = 'Mongo masker'
  s.description = 'Masking production data mongodb for testing/development'
  s.authors     = ['Clicia Scarlet']
  s.email       = ['pnvduc@gmail.com']
  s.files    = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  s.bindir   = 'bin'
  s.executables = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.require_paths = ['lib']
  s.homepage    = 'https://github.com/basicinc/Masker'
  s.license     = 'MIT'

  s.add_runtime_dependency 'thor'
  s.add_runtime_dependency 'mongo'
  s.add_runtime_dependency 'ffaker'
  s.add_runtime_dependency 'irb'

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rake'
end
