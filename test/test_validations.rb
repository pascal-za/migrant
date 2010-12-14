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

end

