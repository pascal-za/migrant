require 'spec_helper'

RSpec::Matchers.define :have_matching_migration do
  match do |template_name|
    matched_migration_file = Dir.glob(Rails.root.join('db', 'migrate', '*.rb')).
                             detect { |f| f.include?(template_name) }
                             
    if matched_migration_file
      migration = File.read(matched_migration_file).strip.gsub(/[\.\(\)]/, '')
      verified_migration_lines = File.read(File.join(File.dirname(__FILE__), 'support', 'verified_migrations', "#{template_name}.rb")).split("\n")
      
      missing_lines = verified_migration_lines.select { |line| !migration.match(line.gsub(/[\.\(\)]/, '').strip) }
      STDERR.puts "The following lines were missing:\n #{missing_lines.join("\n")}" if missing_lines.any?
      
      missing_lines.none?
    end
  end
end

RSpec.describe Migrant::MigrationGenerator do
  context 'from scratch' do
    before(:all) { reset_database! }

    it 'creates migrations for all new tables' do
      expect(described_class.new.run).to be true
      
      generated_migrations = Dir.glob(Rails.root.join('db', 'migrate', '*.rb'))
      
      expect(generated_migrations.length).to eq(5)
      
      # For all the migrations generated into db/migrate, verify
      # them against the pre-verified template
      generated_migrations.each do |migration_file|
        template_name = migration_file.sub(/^.*\d+_/, '').sub('.rb', '')
        
        expect(template_name).to have_matching_migration
      end
    end    
  end
    
  def generated_migrations
    Dir.glob(Rails.root.join('db', 'migrate', '*.rb'))
  end
  
  context 'after initial migration' do
    before(:all) do
      # Do initial migration
      reset_database!
      run_db_upgrade!
    end
    
    it 'generates a migration for new added fields' do
      Business.structure do
        estimated_value 5000.0
        notes
      end     
      
      run_db_upgrade!      
      expect('estimated_value_notes').to have_matching_migration
    end
    
    it 'generates a migration to alter existing columns where no data loss would occur' do
      Business.structure do
        landline :text
      end
      
      run_db_upgrade!      
      expect('landline').to have_matching_migration
    end
    
    it 'generates created_at and updated_at when given the column timestamps' do
      Business.structure do
        timestamps
      end
      
      run_db_upgrade!
      expect('created_at').to have_matching_migration
    end
    
    it 'prompts the user to confirm changing existing columns where data loss may occur' do
      STDIN._mock_responses('N')

      Business.structure do
        landline :integer # Was previously a string, which obviously may incur data loss
      end
      
      expect {
        described_class.new.run
      }.not_to change {
        generated_migrations.length
      }
      
      Business.structure do
        landline :text # Undo our bad for the next tests
      end
    end
    
    it 'exits immediately if there are pending migrations' do
     manual_migration = Rails.root.join("db/migrate/9999999999999999_my_new_migration.rb")
     
     File.open(manual_migration, 'w') { |f| f.write ' ' }
     
     ran = described_class.new.run
     File.delete(manual_migration)
     
     expect(ran).to be false
    end
    
    it 'still creates sequential migrations for the folks not using timestamps' do
      Business.structure do
        new_field_i_made_up
      end
      
      # Remove migrations
      ActiveRecord::Base.timestamped_migrations = false
      run_db_upgrade!
      ActiveRecord::Base.timestamped_migrations = true

      new_migrations = generated_migrations.select { |migration_file| migration_file.include?('new_field_i_made_up') }

      expect(new_migrations.length).to eq(1)
    end
    
    it 'updates a column to include a new default' do
      Business.structure do
        verified true, :default => true
      end
      
      run_db_upgrade!
      expect('modified_verified').to have_matching_migration    
    end
    
    it 'updates indexes on a model' do
      Business.structure do
        name "The Kernel's favourite fried chickens.", :index => true
      end
      
      run_db_upgrade!
      expect('businesses_indexed_name').to have_matching_migration    
    end

    it 'does not remove columns when the user does not confirm' do
      Chameleon.reset_structure!
      Chameleon.no_structure

      STDIN._mock_responses('D', 'n')

      expect {      
        run_db_upgrade!
      }.not_to change { generated_migrations.length }
    end
    
    it 'removes columns when requested and confirmed by the user' do
      Chameleon.reset_structure!
      Chameleon.no_structure

      STDIN._mock_responses('D', 'y')
      
      run_db_upgrade!
      expect('deleted_spots').to have_matching_migration
    end
        
    it 'renames a column missing from the schema to a new column specified by the user' do      
      Chameleon.structure do
        old_spots
      end
      
      run_db_upgrade!
      
      Chameleon.reset_structure!
      Chameleon.structure do
        new_spots
      end
      STDIN._mock_responses('M', 'new_spots')
      
      run_db_upgrade!
      expect('renamed_old_spots').to have_matching_migration
    end
    
    it 'transfers data to an new incompatible column if the operation is safe' do
      Chameleon.reset_column_information
      Chameleon.create!(:new_spots => "22")
      Chameleon.reset_structure!
      Chameleon.structure do
        new_longer_spots "100", :as => :text
      end
      STDIN._mock_responses('M', 'new_longer_spots', 'M')
      
      run_db_upgrade!
      expect('chameleons_added_new_longer_spots_and_moved_new_spots').to have_matching_migration

      Chameleon.reset_column_information
      expect(Chameleon.first.new_longer_spots).to eq("22")
    end
    
    it "removes any column if a user elects to when a column can't be moved due to incompatible types" do
      Chameleon.reset_structure!
      Chameleon.structure do
        incompatible_spot 5
      end

      STDIN._mock_responses('M', 'incompatible_spot', 'N', 'Y')
      run_db_upgrade!
      expect('added_incompatible_spot_and_deleted_new_longer_spots').to have_matching_migration
    end
    
    it 'recursively generates mocks for every model' do
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
      run_db_upgrade!
      
      BusinessCategory.reset_column_information
      m = BusinessCategory.mock!
      mock = BusinessCategory.last

      expect(mock).to_not be_nil
      expect(mock.test_mockup_of_text).to be_a(String)
      expect(mock.test_mockup_of_string).to be_a(String)            
      expect(mock.test_mockup_of_integer).to be_a(Fixnum)
      expect(mock.test_mockup_of_float).to be_a(Float)
      expect(mock.test_mockup_of_currency).to be_a(BigDecimal)
      expect(mock.test_mockup_of_datetime).to be_a(Time)
      expect(DataType::Base.default_mock).to be_a(String)
      expect(mock.test_mockup_serialized).to be_a(Hash)
      expect(mock.test_mockup_hash).to be_a(OpenStruct)
      expect(mock.test_mockup_hash.a).to eq('b')
      expect(mock.test_mockup_serialized_example).to be_a(OpenStruct)
      expect(mock.test_mockup_serialized_example.c).to eq('d')
    end
    
    it 'not rescursively generate mocks for an inherited model when prohibited by the user' do
      category_mock = BusinessCategory.mock!({}, false)
      expect(category_mock).to_not be_nil
    end
    
    it 'generates example mocks for an inherited model when STI is in effect' do
      expect(Customer.mock.average_rating).to eq(5.0)
      expect(Customer.mock.email).to eq("somebody@somewhere.com")
      expect(Customer.mock).to be_a(Customer)
    end
  end
end