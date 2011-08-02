require 'helper'

def assert_schema(model, name, options = {})
  field = model.schema.column_migrations.detect {|m| m.first == name}
  assert_not_nil(field, 'Migration was not generated')
  options.each do |key, correct_value|
    assert_equal(correct_value, field[1][key])
  end
end

class TestDataSchema < Test::Unit::TestCase
  context "The schema generator" do
    should "generate a foreign key field for a belongs_to association" do
      assert_schema(Business, :user_id, :type => :integer)
      assert_schema(BusinessCategory, :business_id, :type => :integer)      
      assert_schema(BusinessCategory, :category_id, :type => :integer)      
    end  
    
    should "generate foreign key fields for a *polymorphic* belongs_to association" do
      assert_schema(Business, :owner_id, :type => :integer)
      assert_schema(Business, :owner_type, :type => :string)
    end  
    
    should "generate a string column when given a string example" do
      assert_schema(Business, :name)
    end

    should "generate a datetime column when given a date or time example" do
      assert_schema(Business, :date_established, :type => :datetime)
      assert_schema(Business, :next_sale, :type => :datetime)      
    end

    should "generate a smallint column when given a small range" do
      assert_schema(Business, :operating_days, :limit => 1, :type => :integer)
    end
    
    should "generate a large integer (size 8) for any bignum types" do
      assert_schema(Category, :serial_number, :limit => 8, :type => :integer)
    end

    should "generate a string column when given a sentence" do
      assert_schema(Business, :summary, :type => :string)
    end
    
    should "generate a text column when given a long paragraph" do
      assert_schema(Business, :address, :type => :text)      
    end
    
    should "pass on any options provided in a structure block" do
      assert_schema(User, :average_rating, :type => :float, :default => 0.0)
    end
    
    should "generate a boolean column when a true or false is given" do
      assert_schema(Business, :verified, :type => :boolean)      
    end
    
    should "generate a column verbatim if no type is specified" do
      assert_schema(Business, :location, :type => :string, :limit => 127)          
    end
    
    should "generate a string column when no options are given" do
      assert_schema(Category, :title, :type => :string)
      assert_schema(Category, :summary, :type => :string)                                      
    end
    
    should "generate a decimal column when a currency is given" do
      assert_schema(User, :money_spent, :type => :decimal, :scale => 2)
      assert_schema(User, :money_gifted, :type => :decimal, :scale => 2)      
    end
    
    should "generate a floating point column when a decimal is given" do
      assert_schema(User, :average_rating, :type => :float)    
    end
    
    should "generate a string column when an email example or class is given" do
      assert_schema(User, :email, :type => :string)    
    end
    
    should "generate indexes for all foreign keys automatically" do
      assert_contains(Business.schema.indexes, :user_id, 'Missing index on belongs_to')
      assert_contains(Business.schema.indexes, [:owner_type, :owner_id], 'Missing index on polymorphic belongs_to')      
      assert_contains(BusinessCategory.schema.indexes, :business_id, 'Missing index on belongs_to')      
      assert_contains(BusinessCategory.schema.indexes, :category_id, 'Missing index on belongs_to')      
    end
    
    should "generate indexes on any column when explicitly asked to" do
      assert_contains(Category.schema.indexes, :title, 'Missing index on :index => true column')
    end 


  end

end
