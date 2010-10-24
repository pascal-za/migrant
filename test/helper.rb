require 'rubygems'
require 'turn' # For nicer output
require 'test/unit'
require 'shoulda'
require 'active_record'

# Reset and load database
db_path = File.join(File.dirname(__FILE__), '..', 'tmp')+'test.sqlite3'
File.delete(db_path) if File.exists?(db_path)

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => db_path
)

# Load our mock models in models/*.rb
# Not including every file in the directory, because some will be used later to mock "new" models
%W{business business_category category user}.each do |model| 
  require(File.join(File.dirname(__FILE__), 'models', model))
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'dataforge'

class Test::Unit::TestCase
end
