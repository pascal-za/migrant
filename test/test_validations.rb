require 'helper'

class TestValidations < Test::Unit::TestCase
  should "validate via ActiveRecord when the validates symbol is supplied" do
    Business.structure do
      website :string, :validates => :presence
    end

    business = Business.create
    assert(business.errors.include?(:website), "Validation was not applied")
  end

  should "validate via ActiveRecord when the full validation hash is supplied" do
    Category.structure do
      summary :string, :validates => { :format => { :with => /Symphony\d/ } }
    end

    bad_category = Category.create
    good_category = Category.create(:summary => "Symphony5")
    assert(bad_category.errors.include?(:summary), "Validation was not applied")
    assert(!good_category.errors.include?(:summary), "Validation options were incorrect")
  end

  should "validate via ActiveRecord when no field name is given" do
    User.structure do
      email :validates => :presence
    end

    user = User.create
    assert(user.errors.include?(:email), "Validation was not applied")
  end
  
  should "validate multiple validations via ActiveRecord when an array is given" do
    Review.structure do
      name "ABCD", :validates => [:presence, {:length => {:maximum => 4}}]
    end    
    
    not_present = Review.create
    too_long = Review.create(:name => "Textthatistoolong")
    correct = Review.create(:name => "ABC")
    
    assert(not_present.errors.include?(:name), "primary validation was not applied")
    assert(too_long.errors.include?(:name), "secondary validation was not applied")
    assert(!correct.errors.include?(:name), "validation for a correct model failed")
    
  end

end

