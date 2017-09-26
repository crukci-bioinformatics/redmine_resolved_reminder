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
  spec.executables   = ["resolvedReminder"]
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "actionpack-xml_parser", "~> 1.0"
  spec.add_runtime_dependency "rake", "~> 10.0"
  spec.add_runtime_dependency "minitest", "~> 5.0"
  spec.add_runtime_dependency "net-ssh", "~> 3.2"
  spec.add_runtime_dependency "mail", "~> 2.6"
  spec.add_runtime_dependency "railties", "4.2.8"
  spec.add_runtime_dependency "activesupport", "4.2.8"
  spec.add_runtime_dependency "activerecord", "4.2.8"
  spec.add_runtime_dependency "rails", "4.2.8"
  spec.add_runtime_dependency "protected_attributes", "~> 1.1"
  spec.add_runtime_dependency "coderay", "~> 1.1"
  spec.add_runtime_dependency "mimemagic", "~> 0.3"
  spec.add_runtime_dependency "mysql2", "~> 0.4"
  spec.add_runtime_dependency "ruby-openid", "~> 2.7"
  spec.add_runtime_dependency "rack-openid", "~> 1.4"
  
end
