class Review < ActiveRecord::Base 
  belongs_to :business
  belongs_to :user
  
  structure do
    name
    rating  -5..5
    body    "Lots of text\nMore text\nMore lines. Etc."
  end
end
