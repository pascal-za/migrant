require 'rubygems'
require 'turn' # For nicer output
require 'test/unit'
require 'shoulda'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'dataforge'

class Test::Unit::TestCase
end
