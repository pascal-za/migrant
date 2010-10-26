require 'simplecov'
require 'fileutils'

SimpleCov.adapters.define 'dataforge' do
  add_filter '/test'
  add_group 'Core Extensions', '/lib/dataforge'
  add_group 'Schema Data Types', '/lib/datatype'
  add_group 'Rake Tasks', '/lib/tasks'
end
SimpleCov.start 'dataforge'
ENV['RAILS_ENV'] = 'test'

require 'rubygems'
require 'turn' # For nicer output
require 'test/unit'
require 'shoulda'

# Must be loaded before appropriate models so we get class method extensions
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))


require 'dataforge'

# Reset and load database
db_path = File.join(File.dirname(__FILE__), 'rails_app', 'db', 'test.sqlite3')
File.delete(db_path) if File.exists?(db_path)

# Remove migrations
Dir.glob(File.join(File.dirname(__FILE__), 'rails_app', 'db', 'migrate', '*')).each do |file|
 File.delete(file)
end

#ActiveRecord::Base.establish_connection(
#  :adapter => "sqlite3",
#  :database => db_path
#)

# Load our mock models in models/*.rb
# Not including every file in the directory, because some will be used later to mock "new" models
#%W{business business_category category user customer}.each do |model| 
#  require(File.join(File.dirname(__FILE__), 'models', model))
#end
require File.join(File.dirname(__FILE__), 'rails_app', 'config', 'environment')

class Test::Unit::TestCase
end
