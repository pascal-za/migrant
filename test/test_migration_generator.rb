require 'helper'
require 'rake'

def rake_migrate
   Dir.chdir(Rails.root.join('.')) do
        Rake::Task['db:migrate'].execute
   end
end

class TestMigrationGenerator < Test::Unit::TestCase
  def generate_migrations
    Profiler.run(:migration_generator) do
      assert_equal true, Migrant::MigrationGenerator.new.run, "Migration Generator reported an error"
    end    
  end

  def run_against_template(template)
    generate_migrations
    Dir.glob(File.join(File.dirname(__FILE__), 'rails_app', 'db' ,'migrate', '*.rb')).each do |migration_file|
        if migration_file.include?(template)
          to_test = File.open(migration_file, 'r') { |r| r.read}.strip
          File.open(File.join(File.dirname(__FILE__), 'verified_output', 'migrations', template+'.rb'), 'r') do |file|
            while (line = file.gets)
              assert_not_nil(to_test.gsub(/[\.\(\)]/, '').match(line.gsub(/[\.\(\)]/, '').strip), "Generated migration #{migration_file} missing line: #{line.gsub(/[\.\(\)]/, '').strip}")
            end
          end
          rake_migrate
          return
        end
    end
    flunk "No migration could be found"
  end
  
  def delete_last_migration
    File.delete(Dir.glob(File.join(File.dirname(__FILE__), 'rails_app', 'db' ,'migrate', '*.rb')).last)
  end

  context "The migration generator" do
    should "create migrations for all new tables" do
      generate_migrations
      Dir.glob(File.join(File.dirname(__FILE__), 'rails_app', 'db' ,'migrate', '*.rb')).each do |migration_file|
         to_test = File.open(migration_file, 'r') { |r| r.read}.strip
         File.open(File.join(File.dirname(__FILE__), 'verified_output', 'migrations', migration_file.sub(/^.*\d+_/, '')), 'r') do |file|
           while (line = file.gets)
             assert_not_nil(to_test.match(line.strip), "Generated migration #{migration_file} missing line: #{line}")
           end
         end
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

    should "generate created_at and updated_at when given the column timestamps" do
      Business.structure do
        timestamps
      end
      run_against_template('created_at')
    end

    should "not change existing columns where data loss may occur" do
      Business.structure do
        landline :integer # Was previously a string, which obviously may incur data loss
      end
      assert_equal(false, Migrant::MigrationGenerator.new.run, "MigrationGenerator ran a dangerous migration!")
      Business.structure do
        landline :text # Undo our bad for the next tests
      end
    end

    should "exit immediately if there are pending migrations" do
     manual_migration = Rails.root.join("db/migrate/9999999999999999_my_new_migration.rb")
     File.open(manual_migration, 'w') { |f| f.write ' ' }
     assert_equal(false, Migrant::MigrationGenerator.new.run)
     File.delete(manual_migration)
    end

    should "still create sequential migrations for the folks not using timestamps" do
      Business.structure do
        new_field_i_made_up
      end
      # Remove migrations
      ActiveRecord::Base.timestamped_migrations = false
      generate_migrations
      ActiveRecord::Base.timestamped_migrations = true

      assert_equal(Dir.glob(File.join(File.dirname(__FILE__), 'rails_app', 'db' ,'migrate', '*.rb')).select { |migration_file| migration_file.include?('new_field_i_made_up') }.length,
                   1,
                   "Migration should have been generated (without a duplicate)")
      rake_migrate                   
    end

    should "recursively generate mocks for every model" do
      BusinessCategory.structure do
        test_mockup_of_text :text
        test_mockup_of_string :string
        test_mockup_of_integer :integer
        test_mockup_of_float   :float
        test_mockup_of_datetime :datetime
        test_mockup_of_currency DataType::Currency
        test_mockup_serialized :serialized
        test_mockup_hash OpenStruct.new({'a' => 'b'})
        test_mockup_serialized_example :serialized, :example => OpenStruct.new({'c' => 'd'})
      end
      

      BusinessCategory.belongs_to(:notaclass, :polymorphic => true)
      generate_migrations
      rake_migrate
      BusinessCategory.reset_column_information
      m = BusinessCategory.mock!
      mock = BusinessCategory.last
      
      assert_not_nil(mock)
      assert(mock.test_mockup_of_text.is_a?(String))
      assert(mock.test_mockup_of_string.is_a?(String))
      assert(mock.test_mockup_of_integer.is_a?(Fixnum))
      assert(mock.test_mockup_of_float.is_a?(Float))
      assert(mock.test_mockup_of_currency.is_a?(BigDecimal))    
      assert(mock.test_mockup_of_datetime.is_a?(Time))    
      assert(DataType::Base.default_mock.is_a?(String))
      assert(mock.test_mockup_serialized.is_a?(Hash))
      assert(mock.test_mockup_hash.is_a?(OpenStruct))
      assert_equal(mock.test_mockup_hash.a, 'b')
      assert(mock.test_mockup_serialized_example.is_a?(OpenStruct))  
      assert_equal(mock.test_mockup_serialized_example.c, 'd')
    end
    
    should "not rescursively generate mocks for an inherited model when prohibited by the user" do
      category_mock = BusinessCategory.mock!({}, false)
      assert_not_nil(category_mock)
    end
        
    should "generate example mocks for an inherited model when STI is in effect" do
      assert_equal(5.00, Customer.mock.average_rating)
      assert_equal("somebody@somewhere.com", Customer.mock.email)
      assert(Customer.mock.is_a?(Customer))
    end
    
    
    should "remove extraneous text from a filename too large for the operating system" do
      BusinessCategory.structure do
        a_very_very_long_field_indeed_far_too_long_for_any_good_use_really true
        a_very_very_long_field_indeed_far_too_long_for_any_good_use_really_2 true
        a_very_very_long_field_indeed_far_too_long_for_any_good_use_really_3 true
      end
      
      BusinessCategory.belongs_to(:verylongclassthatissuretogenerateaverylargeoutputfilename)
      generate_migrations
      delete_last_migration # Can't actually test migration because the index name is too long!
#      BusinessCategory.schema.undo_structure_column(:verylongclassthatissuretogenerateaverylargeoutputfilename_id)
      BusinessCategory.reset_structure!
    end

    should "remove columns when requested and confirmed by the user" do
      Chameleon.structure 
      Chameleon.reset_structure!
      Chameleon.no_structure
      
      STDIN._mock_responses('D', 'y')
      run_against_template('deleted_incompatible_spot')
    end
    
    should "not remove columns when the user does not confirm" do
      Chameleon.reset_structure!
      Chameleon.no_structure
      
      STDIN._mock_responses('D', 'n')
      generate_migrations
      rake_migrate
      Chameleon.structure do
        spots
      end
    end
    
    should "successfully rename a column missing from the schema to a new column specified by the user" do
      Chameleon.structure do
        old_spots
      end
      generate_migrations
      rake_migrate
      Chameleon.reset_structure!
      Chameleon.structure do
        new_spots
      end
      STDIN._mock_responses('M', 'new_spots')
      run_against_template('renamed_old_spots')
    end
    
    should "transfer data to an new incompatible column if the operation is safe" do
      Chameleon.reset_column_information
      Chameleon.create!(:new_spots => "22")
      Chameleon.reset_structure!      
      Chameleon.structure do
        new_longer_spots "100", :as => :text
      end
      STDIN._mock_responses('M', 'new_longer_spots', 'M')
      run_against_template('chameleons_added_new_longer_spots_and_moved_new_spots')
      Chameleon.reset_column_information
      assert_equal(Chameleon.first.new_longer_spots, "22")
    end
    
    should "remove any column if a user elects to when a column can't be moved due to incompatible types" do
      Chameleon.reset_structure!  
      Chameleon.structure do
        incompatible_spot 5
      end
      
      STDIN._mock_responses('M', 'incompatible_spot', 'N', 'Y')
      run_against_template('added_incompatible_spot_and_deleted_spots')
    end
  end
end

