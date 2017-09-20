# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'redmineResolvedReminder/constants'

Gem::Specification.new do |spec|
  spec.name          = RedmineResolvedReminder::PACKAGE
  spec.version       = RedmineResolvedReminder::VERSION
  spec.authors       = ["Gord Brown"]
  spec.email         = ["gdbzork@gmail.com"]

  spec.summary       = %q{Remind users of resolved issues that could be closed.}
  spec.homepage      = "https://github.com/gdbzork/redmine_resolved_reminder"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = ["resolved_reminder"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "actionpack-xml_parser"
  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "net-ssh", "~> 3.2"
  spec.add_development_dependency "mail", "~> 2.6"
  spec.add_development_dependency "railties", "4.2.8"
  spec.add_development_dependency "activesupport", "4.2.8"
  spec.add_development_dependency "activerecord", "4.2.8"
  spec.add_development_dependency "rails", "4.2.8"
  spec.add_development_dependency "protected_attributes"
  spec.add_development_dependency "coderay"
  spec.add_development_dependency "mimemagic"
  spec.add_runtime_dependency "mysql2"
  spec.add_runtime_dependency "ruby-openid"
  spec.add_runtime_dependency "rack-openid"
  
end
