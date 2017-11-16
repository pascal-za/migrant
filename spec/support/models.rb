class Business < ActiveRecord::Base
  belongs_to :user
  belongs_to :owner, :polymorphic => true

  has_many :business_categories
  has_many :categories, :through => :business_categories
  
  structure do
    name             "The Kernel's favourite fried chickens", :was => :title
    website          "http://www.google.co.za/", :was => [:site, :homepage], :validates => :presence
    address          ["11 Test Drive", "Gardens", "Cape Town" ,"South Africa"].join("\n")
    summary          :string
    description      "Founded in 1898", :as => :text
    landline         :string
    mobile           :string
    operating_days   0..6
    date_established :datetime
    date_registered  Date.today - 10.years
    next_sale        (Time.now + 10.days)
    verified         false, :default => false
    location         :type => :string, :limit => 127
    awards           ["Best business 2007", "Tastiest Chicken 2008"]
    managers         :serialized
  end
end

class BusinessCategory < ActiveRecord::Base
  belongs_to :business
  belongs_to :category
  
  no_structure
end

class Category < ActiveRecord::Base
  has_many :business_categories
  has_many :businesses, :through => :business_categories
  
  structure do
    title :index => true # Default type is a good 'ol varchar(255)
    summary
    serial_number 1234567891011121314
  end
end

class Chameleon < ActiveRecord::Base
  structure do
    spots
  end
end

class User < ActiveRecord::Base
  structure do
    name               nil # Testing creating from an unknown class
    email              "somebody@somewhere.com"
    encrypted_password :limit => 48
    password_salt      :limit => 42
  end
end

class Customer < User
  belongs_to :category

  structure do
    money_spent   "$5.00"
    money_gifted  "NOK 550.00" 
    average_rating 5.00, :default => 0.0
  end
end

class NonMigrantModel < ActiveRecord::Base
  belongs_to :business
end
