require 'helper'
require 'rake'

class TestMigrationGenerator < Test::Unit::TestCase
  context "The migration generator" do
    should "do something" do
      DataForge::MigrationGenerator.new.run
    end
  end
end
 
