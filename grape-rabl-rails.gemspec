# -*- encoding: utf-8 -*-
require File.expand_path('../lib/grape-rabl-rails/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Piotr Niełacny", "Marcello Barnaba"]
  gem.email         = ["piotr.nielacny@gmail.com", "vjt@openssl.it"]
  gem.description   = %q{Use rabl-rails in grape}
  gem.summary       = %q{Use rabl-rails in grape}
  gem.homepage      = "https://github.com/ifad/grape-rabl-rails"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "grape-rabl-rails"
  gem.require_paths = ["lib"]
  gem.version       = Grape::RablRails::VERSION
  gem.required_ruby_version = '>= 1.9.3'

  gem.add_dependency "grape", '>= 0.12.0'
  gem.add_dependency "rabl-rails"
  gem.add_dependency "i18n"
end
