require 'helper'
require 'rake'

class TestMigrationGenerator < Test::Unit::TestCase
  context "The migration generator" do
    should "do something" do
      assert DataForge::MigrationGenerator.new.run, "Migration Generator reported an error"
    end
  end
end
 
