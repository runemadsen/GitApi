# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "git-api/version"

Gem::Specification.new do |s|
  s.name        = "git-api"
  s.version     = GitApi::VERSION
  s.authors     = ["Rune Madsen"]
  s.email       = ["rune@runemadsen.com"]
  s.homepage    = ""
  s.summary     = "Exposes your Git repositories via HTTP"
  s.description = "Exposes your Git repositories via HTTP"

  s.rubyforge_project = "git-api"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rack-test"
  s.add_runtime_dependency "json"
  s.add_runtime_dependency "sinatra", "~> 1.3.2"
  s.add_runtime_dependency "grit", "~> 2.5.0"
  s.add_runtime_dependency "github-linguist", "~> 2.0.1"
end
