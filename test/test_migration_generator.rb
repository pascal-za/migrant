require 'helper'
require 'rake'

def rake_migrate
   Dir.chdir(Rails.root.join('.')) do
        Rake::Task['db:migrate'].execute
   end        
end


class TestMigrationGenerator < Test::Unit::TestCase
  def run_against_template(template)
    assert_equal true, DataForge::MigrationGenerator.new.run, "Migration Generator reported an error"
    Dir.glob(File.join(File.dirname(__FILE__), 'rails_app', 'db' ,'migrate', '*.rb')).each do |migration_file|
        if migration_file.include?(template)
          correct = File.join(File.dirname(__FILE__), 'verified_output', 'migrations', template+'.rb')
          assert_equal(File.open(correct, 'r') { |r| r.read}.strip,
                       File.open(migration_file, 'r') { |r| r.read}.strip, 
                       "Generated migration #{migration_file} does not match template #{correct}")
          rake_migrate
          return
        end
    end
    flunk "No migration could be found"            
  end

  context "The migration generator" do
    should "create migrations for all new tables" do
      assert_equal true, DataForge::MigrationGenerator.new.run, "Migration Generator reported an error"
      Dir.glob(File.join(File.dirname(__FILE__), 'rails_app', 'db' ,'migrate', '*.rb')).each do |migration_file|
         correct = File.join(File.dirname(__FILE__), 'verified_output', 'migrations', migration_file.sub(/^.*\d+_/, ''))
         assert_equal(File.open(correct, 'r') { |r| r.read}.strip,
                      File.open(migration_file, 'r') { |r| r.read}.strip,
                      "Generated migration #{migration_file} does not match template #{correct}")
      end
      rake_migrate
    end
    
    should "generate a migration for new added fields" do
      Business.structure do
        estimated_value 5000.0
        notes
      end
      run_against_template('estimated_value_notes')
    end
    
    should "generate a migration to alter existing columns where no data loss would occur" do
      Business.structure do
        landline :text
      end
      
      run_against_template('landline')
    end
    
    should "generate a migration to alter existing columns while adding a new table" do
      load File.join(File.dirname(__FILE__), 'additional_models', 'review.rb')
      User.belongs_to(:business) # To generate a business_id on a User
      User.no_structure # To force schema update
      
      run_against_template('create_reviews')
      run_against_template('business_id')
    end
    
    should "not change existing columns where data loss may occur" do
      Business.structure do
        landline :integer # Was previously a string, which obviously may incur data loss      
      end
      assert_equal(false, DataForge::MigrationGenerator.new.run, "MigrationGenerator ran a dangerous migration!")   
      Business.structure do
        landline :text # Undo our bad for the next tests
      end   
    end
    
    should "exit immediately if there are pending migrations" do
     manual_migration = Rails.root.join("db/migrate/9999999999999999_my_new_migration.rb")
     File.open(manual_migration, 'w') { |f| f.write ' ' }
     assert_equal(false, DataForge::MigrationGenerator.new.run)
     File.delete(manual_migration)
    end
    
    should "still create sequential migrations for the folks not using timestamps" do
      Business.structure do
        new_field_i_made_up
      end
      # Remove migrations
      ActiveRecord::Base.timestamped_migrations = false
      assert_equal true, DataForge::MigrationGenerator.new.run, "Migration Generator reported an error"
      ActiveRecord::Base.timestamped_migrations = true      
      
      assert_equal(Dir.glob(File.join(File.dirname(__FILE__), 'rails_app', 'db' ,'migrate', '*.rb')).select { |migration_file| migration_file.include?('new_field_i_made_up') }.length,
                   1,
                   "Migration should have been generated (without a duplicate)")
    end

  end
end
 
