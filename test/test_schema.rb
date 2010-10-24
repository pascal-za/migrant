require 'helper'

def assert_schema(migrations, name, options = {})
  field = migrations.detect {|m| m.first == name}
  assert_not_nil(field, 'Migration was not generated')
  options.each do |key, correct_value|
    assert_equal(correct_value, field[1][key])
  end
end

class TestSchema < Test::Unit::TestCase
  context "The schema generator" do
    should "generate a foreign key field for a belongs_to association" do
      assert_schema(Business.schema.column_migrations, :user_id, :type => :integer)
      assert_schema(BusinessCategory.schema.column_migrations, :business_id, :type => :integer)      
      assert_schema(BusinessCategory.schema.column_migrations, :category_id, :type => :integer)      
    end  
    
    should "generate foreign key fields for a *polymorphic* belongs_to association" do
      assert_schema(Business.schema.column_migrations, :owner_id, :type => :integer)
      assert_schema(Business.schema.column_migrations, :owner_type, :type => :string)
    end  
    
    should "generate a string column when given a string example" do
      assert_schema(Business.schema.column_migrations, :name)
    end

    should "generate a datetime column when given a date or time example" do
      assert_schema(Business.schema.column_migrations, :date_established, :type => :datetime)
      assert_schema(Business.schema.column_migrations, :next_sale, :type => :datetime)      
    end

    should "generate a smallint column when given a small range" do
      assert_schema(Business.schema.column_migrations, :operating_days, :limit => 1, :type => :integer)
    end

    should "generate a string column when given a sentence" do
      assert_schema(Business.schema.column_migrations, :summary, :type => :string)
    end
    
    should "generate a text column when given a long paragraph" do
      assert_schema(Business.schema.column_migrations, :description, :type => :text)
      assert_schema(Business.schema.column_migrations, :address, :type => :text)      
    end
    
    should "generate a boolean column when a true or false is given" do
      assert_schema(Business.schema.column_migrations, :verified, :type => :boolean)      
    end
    
    should "generate a column verbatim if no type is specified" do
      assert_schema(Business.schema.column_migrations, :location, :type => :string, :limit => 127)          
    end
    
    should "generate a string column when no options are given" do
      assert_schema(Category.schema.column_migrations, :title, :type => :string)
      assert_schema(Category.schema.column_migrations, :summary, :type => :string)                                      
    end
    
    should "generate a decimal column when a currency is given" do
      assert_schema(Customer.schema.column_migrations, :money_spent, :type => :decimal, :scale => 2)
      assert_schema(Customer.schema.column_migrations, :money_gifted, :type => :decimal, :scale => 2)      
    end
    
    should "generate a double column when a decimal is given" do
      assert_schema(Customer.schema.column_migrations, :average_rating, :type => :double)    
    end

  end

end
