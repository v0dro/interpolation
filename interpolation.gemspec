Gem::Specification.new do |gem|
  gem.name          = "interpolation"
  gem.version       = "0.0.1"
  gem.summary       = "Interpolation routines in ruby. Works with NMatrix."
  gem.description   = "Interpolation is a library for executing various interpolation functions in Ruby. Works with NMatrix."
  gem.homepage      = 'https://github.com/v0dro/interpolation'
  gem.authors       = ['Sameer Deshmukh'] 
  gem.email         =  ['sameer.deshmukh93@gmail.com']
  gem.license       = 'BSD 3-clause'
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.require_paths = ["lib"]

  gem.required_ruby_version = '>= 1.9.3'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'

  gem.add_runtime_dependency 'nmatrix', '~>0.0.9'
end