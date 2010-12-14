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

require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.name = "migrant"
  gem.summary = %Q{All the fun of ActiveRecord, without writing your migrations, and a dash of mocking.}
  gem.description = %Q{Migrant gives you a super-clean DSL to describe your ActiveRecord models (somewhat similar to DataMapper) and generates all your migrations for you so you can spend more time coding the stuff that counts!}
  gem.email = "101pascal@gmail.com"
  gem.homepage = "http://github.com/pascalh1011/migrant"
  gem.authors = ["Pascal Houliston"]
  gem.add_development_dependency "bundler"
  gem.add_runtime_dependency "rails", ">= 3.0.0"
  # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
end
Jeweler::RubygemsDotOrgTasks.new

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

