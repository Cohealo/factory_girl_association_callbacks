# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'factory_girl_association_callbacks/version'

Gem::Specification.new do |spec|
  spec.name          = "factory_girl_association_callbacks"
  spec.version       = FactoryGirlAssociationCallbacks::VERSION
  spec.authors       = ["Andy Hartford"]
  spec.email         = ["andy.hartford@cohealo.com"]
  spec.summary       = %q{Strategies for factory girl that add before and after callbacks to association attributes}
  spec.homepage      = "https://github.com/Cohealo/factory_girl_association_callbacks"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "factory_girl", ">= 4.4"
  spec.add_development_dependency "rspec", ">= 3.1"
  spec.add_development_dependency "guard-rspec"
end
