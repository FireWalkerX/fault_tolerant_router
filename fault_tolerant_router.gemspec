# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fault_tolerant_router/version'

Gem::Specification.new do |spec|
  spec.name = 'fault_tolerant_router'
  spec.version = FaultTolerantRouter::VERSION
  spec.authors = ['Alessandro Zarrilli']
  spec.email = ['alessandro@zarrilli.net']
  #todo: fix descriptions
  spec.summary = %q{Multiple uplinks routing supervising daemon}
  spec.description = %q{A daemon, running in background on a Linux router or firewall, monitoring the state of multiple internet uplinks/providers and changing the routing accordingly. Outgoing connections are spread through the uplinks in a load balancing fashion via Linux multipath routing. Fault Tolerant Router monitors the state of the uplinks by routinely pinging well known IP addresses (for example Google public DNS servers) through each outgoing interface. Once an uplink goes down, it is excluded from the multipath routing. When it comes back up, it is included again. All of the routing changes are notified by email to the administrator.}
  spec.homepage = 'https://github.com/drsound/fault_tolerant_router'
  spec.license = 'GPL-2'

  spec.files = `git ls-files -z`.split("\x0")
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_runtime_dependency 'mail', '~> 2.6'
end
