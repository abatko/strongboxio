lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'strongboxio.rb'

Gem::Specification.new do |s|
  s.name        = 'strongboxio'
  s.version     = Strongboxio::VERSION

  s.summary     = 'Decrypt and read www.Strongbox.io files'
  s.description = "#{s.summary}."

  s.authors     = ['Alex Batko']
  s.email       = ['alexbatko@gmail.com']

  s.homepage    = 'https://github.com/abatko/strongboxio'

  s.files       = ['lib/strongboxio.rb']
  s.test_files  = Dir["test/**/*"]

  s.license     = 'MIT'
end
