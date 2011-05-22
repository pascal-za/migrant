require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "migrant"
    gem.summary = %Q{All the fun of ActiveRecord, without writing your migrations, and a dash of mocking.}
    gem.description = %Q{Easier schema management for Rails that compliments your domain model.}
    gem.email = "101pascal@gmail.com"
    gem.homepage = "http://github.com/pascalh1011/migrant"
    gem.authors = ["Pascal Houliston"]
    gem.version = File.read('VERSION')

    gem.add_runtime_dependency "rails", ">= 3.0.0"
    gem.add_runtime_dependency "faker"
    gem.add_runtime_dependency "term-ansicolor"
    
    gem.add_development_dependency "thoughtbot-shoulda"
    gem.add_development_dependency "ansi"
    gem.add_development_dependency "jeweler"
    gem.add_development_dependency "turn"
    gem.add_development_dependency "sqlite3"
    gem.add_development_dependency "simplecov"
    gem.add_development_dependency "terminal-table"
    gem.add_development_dependency "term-ansicolor"
    gem.add_development_dependency "rake", "0.8.7" # Until API gets sorted

    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new

rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "migrant #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

