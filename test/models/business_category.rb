class BusinessCategory < ActiveRecord::Base
  belongs_to :business
  belongs_to :category
  
  no_structure
end
