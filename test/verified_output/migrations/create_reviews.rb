class CreateReviews < ActiveRecord::Migration
  def self.up
    create_table :reviews do |t|
      t.integer :business_id
      t.integer :user_id
      t.string :name
      t.integer :rating, :limit=>1
      t.text :body
      t.integer :views
    end
    add_index :reviews, :business_id
    add_index :reviews, :user_id
  end
  
  def self.down
    drop_table :reviews
  end
end
