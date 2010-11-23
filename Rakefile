require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "migrant"
    gem.summary = %Q{All the fun of ActiveRecord, without writing your migrations, and a dash of mocking.}
    gem.description = %Q{Migrant gives you a super-clean DSL to describe your ActiveRecord models (somewhat similar to DataMapper) and generates all your migrations for you so you can spend more time coding the stuff that counts!}
    gem.email = "101pascal@gmail.com"
    gem.homepage = "http://github.com/pascalh1011/migrant"
    gem.authors = ["Pascal Houliston"]
    gem.add_development_dependency "thoughtbot-shoulda", ">= 0"
    gem.add_development_dependency "ansi", "= 1.2.2"
    gem.add_development_dependency "turn", "= 0.8.1"  
    gem.add_development_dependency "sqlite3-ruby", ">= 0"
    gem.add_development_dependency "simplecov", "= 0.3.5"
    gem.add_dependency "rails", ">= 3.0.0"
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

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "migrant #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
