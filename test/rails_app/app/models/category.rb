class Category < ActiveRecord::Base
  has_many :business_categories
  has_many :businesses, :through => :business_categories
  
  structure do
    title :index => true, :unique => true # Default type is a good 'ol varchar(255)
    summary
  end
end
