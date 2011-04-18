class Category < ActiveRecord::Base
  has_many :business_categories
  has_many :businesses, :through => :business_categories
  
  structure do
    title :index => true # Default type is a good 'ol varchar(255)
    summary
    serial_number 1234567891011121314
  end
end
