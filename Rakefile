lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
require 'strongboxio/version'

require 'rake/testtask'

Rake::TestTask.new do |t|
	t.libs << 'test'
end

desc 'Run tests'
task :default => :test

desc 'Build gem'
task :build do
	system 'gem build strongboxio.gemspec'
end

desc 'Release gem'
task :release => :build do
	system "gem push strongboxio-#{Strongboxio::VERSION}.gem"
end

