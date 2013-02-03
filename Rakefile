require 'rubygems'
require 'bundler'
require 'simplecov'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

SimpleCov.adapters.define 'migrant' do
  add_filter '/test'
  add_filter '/lib/tasks'
  add_filter '/lib/railtie' # Not covering lines it's running here .. disabling for now
  add_filter '/lib/simple_object'

  add_group 'Core Extensions', '/lib/migrant'
  add_group 'Schema Data Types', '/lib/datatype'
end
SimpleCov.start 'migrant'

require 'rake'
require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test

