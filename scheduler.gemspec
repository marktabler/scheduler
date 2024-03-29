# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.authors       = ["Mark Tabler\n"]
  gem.email         = ["mark.tabler@fallingmanstudios.net"]
  gem.description   = %q{Sets up the queue for ferret dispatchers}
  gem.summary       = %q{Link between dispatcher & command center}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "scheduler"
  gem.require_paths = ["lib"]
  gem.version       = '1.0.0'
end
