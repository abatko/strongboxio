lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'strongboxio/version'

Gem::Specification.new do |s|
	s.name        = 'strongboxio'
	s.version     = Strongboxio::VERSION

	s.summary     = 'Decrypt and read www.Strongbox.io files'
	s.description = "#{s.summary}. This is a combination gem and command-line utility."

	s.authors     = ['Alex Batko']
	s.email       = ['alexbatko@gmail.com']

	s.homepage    = 'https://github.com/abatko/strongboxio'

	s.add_runtime_dependency 'nokogiri'
	s.add_runtime_dependency 'highline'

	s.files         = `git ls-files`.split($/)
	s.executables   = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
	s.test_files    = s.files.grep(%r{^(test|spec|features)/})
	s.require_paths = ['lib']

	s.license = 'MIT'
end

