require 'spec_helper'

RSpec::Matchers.define :include_matching_schema do |name, options|
  match do |model|
    field = model.schema.column_migrations.detect {|m| m.first == name }
    
    field && options.all? do |key, expected_value|
      field[1][key] == expected_value
    end
  end
end

RSpec::Matchers.define :include_schema_index_on do |column_name|
  match do |model|
    model.schema.indexes.include?(column_name)
  end
end

RSpec.describe Migrant::ModelExtensions do
  context "The schema generator" do
    it "generates a foreign key field for a belongs_to association" do
      expect(Business).to include_matching_schema(:user_id, type: :integer)
      expect(BusinessCategory).to include_matching_schema(:business_id, type: :integer)
      expect(BusinessCategory).to include_matching_schema(:category_id, type: :integer)
      expect(User).to include_matching_schema(:category_id, type: :integer)
    end  
    
    it "generates foreign key fields for a *polymorphic* belongs_to association" do
      expect(Business).to include_matching_schema(:owner_id, type: :integer)
      expect(Business).to include_matching_schema(:owner_type, type: :string)
    end  
    
    it "generates a string column when given a string example" do
      expect(Business).to include_matching_schema(:name, {})
    end

    it "generates a datetime column when given a date or time example" do
      expect(Business).to include_matching_schema(:date_established, type: :datetime)
      expect(Business).to include_matching_schema(:next_sale, type: :datetime)
      expect(Business).to include_matching_schema(:date_registered, type: :date)
    end

    it "generates a smallint column when given a small range" do
      expect(Business).to include_matching_schema(:operating_days, type: :integer)
    end
    
    it "generates a large integer (size 8) for any bignum types" do
      expect(Category).to include_matching_schema(:serial_number, {
        type: :integer,
        limit: 8
      })
    end

    it "generates a string column when given a sentence" do
      expect(Business).to include_matching_schema(:summary, type: :string)
    end
    
    it "generates a text column when given a long paragraph" do
      expect(Business).to include_matching_schema(:address, type: :text)
    end
    
    it "passes on any options provided in a structure block" do
      expect(User).to include_matching_schema(:average_rating, {
        type: :float,
        default: 0.0
      })
    end
    
    it "generates a boolean column when a true or false is given" do
      expect(Business).to include_matching_schema(:verified, type: :boolean)
    end
    
    it "generates a column verbatim if no type is specified" do
      expect(Business).to include_matching_schema(:location, {
        type: :string,
        limit: 127
      })
    end
    
    it "generates a string column when no options are given" do
      expect(Category).to include_matching_schema(:title, type: :string)
      expect(Category).to include_matching_schema(:summary, type: :string)
    end
    
    it "generates a decimal column when a currency is given" do
      expect(User).to include_matching_schema(:money_spent, type: :decimal, scale: 2)
      expect(User).to include_matching_schema(:money_gifted, type: :decimal, scale: 2)
    end
    
    it "generates a floating point column when a decimal is given" do
      expect(User).to include_matching_schema(:average_rating, type: :float)
    end
    
    it "generates a string column when an email example or class is given" do
      expect(User).to include_matching_schema(:email, type: :string)
    end
    
    it "generates indexes for all foreign keys automatically" do
      expect(Business).to include_schema_index_on(:user_id)
      expect(Business).to include_schema_index_on([:owner_type, :owner_id])
      
      expect(BusinessCategory).to include_schema_index_on(:business_id)
      expect(BusinessCategory).to include_schema_index_on(:category_id)
    end
    
    it "generates indexes on any column when explicitly asked to" do
      expect(Category).to include_schema_index_on(:title)
    end 
    
    it "generates a text column for serialized fields" do      
      expect(Business).to include_matching_schema(:awards, type: :text)
      expect(Business).to include_matching_schema(:managers, type: :text)

      expect(Business.schema.columns[:awards].mock.class).to eq(Array)
      expect(Business.schema.columns[:managers].mock.class).to eq(Hash)
      
      expect(Business.schema.columns[:awards].serialized?).to be true
      expect(Business.schema.columns[:managers].serialized?).to be true
    end

    it "still indicates a structure is not defined if a belongs_to association is added" do
      expect(NonMigrantModel.structure_defined?).to be false
      expect(Business.structure_defined?).to be true
    end
  end
  
  context "validations" do
    before(:all) do
      reset_database!
      run_db_upgrade!
    end
    
    it 'validates via ActiveRecord when the validates symbol is supplied' do
      Business.structure do
        website :string, :validates => :presence
      end

      business = Business.create
      expect(business.errors).to include(:website)
    end
    
    it 'validate via ActiveRecord when the full validation hash is supplied' do
      Category.structure do
        summary :string, :validates => { :format => { :with => /Symphony\d/ } }
      end

      bad_category = Category.create
      good_category = Category.create(:summary => "Symphony5")
      
      expect(bad_category.errors).to include(:summary)
      expect(good_category.errors).to_not include(:summary)
    end
    
    it 'validates via ActiveRecord when no field name is given' do
      User.structure do
        email :validates => :presence
      end

      user = User.create
      expect(user.errors).to include(:email)
    end
    
    it 'validate multiple validations via ActiveRecord when an array is given' do
      User.structure do
        name "ABCD", :validates => [:presence, {:length => {:maximum => 4}}]
      end    
    
      not_present = User.create
      too_long = User.create(:name => "Textthatistoolong")
      correct = User.create(:name => "ABC")
            
      expect(not_present.errors).to include(:name)
      expect(too_long.errors).to include(:name)
      expect(correct.errors).to_not include(:name)
    end
  end
end