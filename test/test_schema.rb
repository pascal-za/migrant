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

  end

end
