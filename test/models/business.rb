class Business < ActiveRecord::Base
  belongs_to :user
  belongs_to :owner, :polymorphic => true

  has_many :business_categories
  has_many :categories, :through => :business_categories
  
  structure do
    name             "The Kernel's favourite fried chickens", :was => :title
    website          "http://www.google.co.za/", :was => [:site, :homepage]
    email            "bob@nowhere.com"
    summary          DataType::Sentence
    description      DataType::Paragraph
    landline         DataType::PhoneNumber
    mobile           DataType::PhoneNumber
    operating_days   0..6
    date_established DataType::Date
    next_sale        (Time.now + 10.days)
    verified         false
    location         :type => :string, :limit => 127
  end
end
