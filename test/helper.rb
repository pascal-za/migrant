require 'simplecov'
require 'fileutils'

SimpleCov.adapters.define 'migrant' do
  add_filter '/test'
  add_filter '/lib/tasks'
  add_filter '/lib/railtie' # Not covering lines it's running here .. disabling for now
  add_filter '/lib/simple_object'
  
  add_group 'Core Extensions', '/lib/migrant'
  add_group 'Schema Data Types', '/lib/datatype'
end
SimpleCov.start 'migrant'
ENV['RAILS_ENV'] = 'test'

require 'rubygems'
require 'turn' # For nicer output
require 'test/unit'
require 'shoulda'

# Must be loaded before appropriate models so we get class method extensions
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))


require 'migrant'

# Reset database
db_path = File.join(File.dirname(__FILE__), 'rails_app', 'db', 'test.sqlite3')
File.delete(db_path) if File.exists?(db_path)

# Remove migrations
Dir.glob(File.join(File.dirname(__FILE__), 'rails_app', 'db', 'migrate', '*')).each do |file|
 File.delete(file)
end

require File.join(File.dirname(__FILE__), 'rails_app', 'config', 'environment')

class Test::Unit::TestCase
end
