# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20101122122964) do

  create_table "business_categories", :force => true do |t|
    t.integer  "business_id"
    t.integer  "category_id"
    t.decimal  "test_currency_mockup", :precision => 10, :scale => 2
    t.datetime "test_date_mockup"
    t.float    "test_float_mockup"
    t.integer  "test_range_mockup"
  end

  add_index "business_categories", ["business_id"], :name => "index_business_categories_on_business_id"
  add_index "business_categories", ["category_id"], :name => "index_business_categories_on_category_id"

  create_table "businesses", :force => true do |t|
    t.integer  "user_id"
    t.string   "owner_type"
    t.integer  "owner_id"
    t.string   "name"
    t.string   "website"
    t.text     "address"
    t.string   "summary"
    t.text     "description"
    t.text     "landline",         :limit => 255
    t.string   "mobile"
    t.integer  "operating_days",   :limit => 1
    t.datetime "date_established"
    t.datetime "next_sale"
    t.boolean  "verified"
    t.string   "location",         :limit => 127
    t.float    "estimated_value"
    t.string   "notes"
  end

  add_index "businesses", ["owner_id"], :name => "index_businesses_on_owner_id"
  add_index "businesses", ["owner_type", "owner_id"], :name => "index_businesses_on_owner_type_and_owner_id"
  add_index "businesses", ["user_id"], :name => "index_businesses_on_user_id"

  create_table "categories", :force => true do |t|
    t.string "title"
    t.string "summary"
  end

  add_index "categories", ["title"], :name => "index_categories_on_title"

  create_table "reviews", :force => true do |t|
    t.integer "business_id"
    t.integer "user_id"
    t.string  "name"
    t.integer "rating",      :limit => 1
    t.text    "body"
  end

  add_index "reviews", ["business_id"], :name => "index_reviews_on_business_id"
  add_index "reviews", ["user_id"], :name => "index_reviews_on_user_id"

  create_table "users", :force => true do |t|
    t.string  "name"
    t.string  "email"
    t.string  "encrypted_password", :limit => 48
    t.string  "password_salt",      :limit => 42
    t.decimal "money_spent",                      :precision => 10, :scale => 2
    t.decimal "money_gifted",                     :precision => 10, :scale => 2
    t.float   "average_rating"
    t.integer "business_id"
  end

  add_index "users", ["business_id"], :name => "index_users_on_business_id"

end
