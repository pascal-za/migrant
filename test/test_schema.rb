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
    should "should generate a foreign key field for a belongs_to association" do
      assert_schema(Business.schema.column_migrations, :user_id, :type => :integer)
      assert_schema(BusinessCategory.schema.column_migrations, :business_id, :type => :integer)      
      assert_schema(BusinessCategory.schema.column_migrations, :category_id, :type => :integer)      
    end  
    
    should "should generate foreign key fields for a *polymorphic* belongs_to association" do
      assert_schema(Business.schema.column_migrations, :owner_id, :type => :integer)
      assert_schema(Business.schema.column_migrations, :owner_type, :type => :string)
    end  

  end

end
