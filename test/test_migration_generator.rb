require 'helper'
require 'rake'

class TestMigrationGenerator < Test::Unit::TestCase
  context "The migration generator" do
    should "create migrations for all new tables" do
      assert_equal true, DataForge::MigrationGenerator.new.run, "Migration Generator reported an error"
      Dir.glob(File.join(File.dirname(__FILE__), 'rails_app', 'db' ,'migrate', '*.rb')).each do |migration_file|
         correct = File.join(File.dirname(__FILE__), 'verified_output', 'migrations', migration_file.sub(/^.*\d+_/, ''))
         assert_equal(File.open(migration_file, 'r') { |r| r.read}.strip, 
                      File.open(correct, 'r') { |r| r.read}.strip,
                      "Generated migration #{migration_file} does not match template #{correct}")
      end
      Dir.chdir(Rails.root.join('.')) do
        Rake::Task['db:migrate'].invoke
      end        
    end
    
    should "generate a migration for new added fields" do
      Business.structure do
        estimated_value 5000.0
        notes
      end
      assert_equal true, DataForge::MigrationGenerator.new.run, "Migration Generator reported an error"
      
      Dir.glob(File.join(File.dirname(__FILE__), 'rails_app', 'db' ,'migrate', '*.rb')).each do |migration_file|
        if migration_file.include?('estimated_value_notes')
          correct = File.join(File.dirname(__FILE__), 'verified_output', 'migrations', 'estimated_value_notes')
          assert_equal(File.open(migration_file, 'r') { |r| r.read}.strip, 
                        File.open(correct, 'r') { |r| r.read}.strip,
                       "Generated migration #{migration_file} does not match template #{correct}")
          return true
        end
      end
      flunk "No migration could be found"      
    end
    
    
    should "exit immediately if there are pending migrations" do
     manual_migration = Rails.root.join("db/migrate/9999999999999999_my_new_migration.rb")
     File.open(manual_migration, 'w') { |f| f.write ' ' }
     assert_equal(false, DataForge::MigrationGenerator.new.run)
     File.delete(manual_migration)
    end

    should "never overwrite an existing migration" do
       manual_migration = Rails.root.join("db/migrate/"+ Time.now.utc.strftime("%Y%m%d%H%M%S").to_s+"1_create_businesses.rb")
       assert_equal(false, DataForge::MigrationGenerator.new.run(true), "The migration was overwritten - bad!")
    end
  end
end
 
