# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "alert_tweeter/version"

Gem::Specification.new do |s|
  s.name        = "alert_tweeter"
  s.version     = AlertTweeter::VERSION
  s.authors     = ["Jonathan D. Simms"]
  s.email       = ["slyphon@gmail.com"]
  s.homepage    = "https://github.com/slyphon/alert_tweeter"
  s.summary     = %q{Nagios alerts go to twitter}
  s.description = s.summary + "\n"

  s.rubyforge_project = "alert_tweeter"

  s.files         = `git ls-files`.split("\n").reject{|n| n =~ /\.gem$/}
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'twitter',       '~> 2.0.2'
  s.add_runtime_dependency 'slop',          '~> 2.4.2'
  s.add_runtime_dependency 'activesupport', '~> 3.1.0'
  s.add_runtime_dependency 'i18n'
end
