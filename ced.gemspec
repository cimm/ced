# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ced/version'

Gem::Specification.new do |gem|
  gem.name          = "CED"
  gem.version       = CED::VERSION
  gem.authors       = ["Simon Schoeters"]
  gem.email         = ["hamfilter@gmail.com"]
  gem.description   = %q{Ruby interface for CED's email verification service.}
  gem.summary       = %q{The Central Email Database is an email verification service. You pass it an email address and it tells you if the email address is real or not. This gem wraps the API in a more Ruby friendly syntax. CED also corrects common typos in email domains.}
  gem.homepage      = "https://github.com/cimm/ced"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency 'webmock', '~> 1.9.0'
  gem.add_development_dependency 'rake',    '~> 10.0.3'
end
