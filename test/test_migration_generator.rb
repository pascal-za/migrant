require 'helper'
require 'rake'

class TestMigrationGenerator < Test::Unit::TestCase
  context "The migration generator" do
    should "do something" do
      assert DataForge::MigrationGenerator.new.run, "Migration Generator reported an error"
    end
    
    should "exit immediately if there are pending migrations" do
     manual_migration = Rails.root.join("db/migrate/2010105121251_my_new_migration.rb")
     File.open(manual_migration, 'w') { |f| f.write ' ' }
     assert_equal(false, DataForge::MigrationGenerator.new.run)
     File.delete(manual_migration)
    end
  end
end
 
