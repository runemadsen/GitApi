# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "git-api/version"

Gem::Specification.new do |s|
  s.name        = "git-api"
  s.version     = GitApi::VERSION
  s.authors     = ["Rune Madsen"]
  s.email       = ["rune@runemadsen.com"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "git-api"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rack-test"
  s.add_runtime_dependency "json"
  s.add_runtime_dependency "sinatra"
  s.add_runtime_dependency "grit"
end
