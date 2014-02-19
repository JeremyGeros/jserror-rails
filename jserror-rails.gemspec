# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name        = "jserror-rails"
  s.version     = "0.6.4"
  s.authors     = ["Jeremy Geros"]
  s.email       = ["jeremy453@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Try catch wrap for sprockets.}
  s.description = %q{Adds try catch around all functions to allow better error debugging in javascript.}

  s.files         = `git ls-files`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

end
