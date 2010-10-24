require 'rubygems'
require 'turn' # For nicer output
require 'test/unit'
require 'shoulda'
require 'active_record'

# Load and reset database
db_path = File.join(File.dirname(__FILE__), '..', 'tmp')+'test.sqlite3'
File.delete(db_path) if File.exists?(db_path)

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => db_path
)

# Load our mock models in models/*.rb
%W{business business_category category review user}.each do |model| 
  require(File.join(File.dirname(__FILE__), 'models', model))
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'dataforge'

class Test::Unit::TestCase
end
