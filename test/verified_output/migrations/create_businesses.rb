class CreateBusinesses < ActiveRecord::Migration
  def self.up
    create_table :businesses do |t|
      t.integer :user_id 
      t.string :owner_type 
      t.integer :owner_id 
      t.string :name 
      t.string :website 
      t.text :address
      t.string :summary 
      t.text :description 
      t.string :landline 
      t.string :mobile 
      t.integer :operating_days
      t.datetime :date_established 
      t.datetime :next_sale 
      t.date :date_registered
      t.boolean :verified
      t.string :location, :limit=>127 
      t.text :awards 
      t.text :managers 
    end
    add_index :businesses, :user_id
    add_index :businesses, [:owner_type, :owner_id]
    add_index :businesses, :owner_id
  end
  
  def self.down
    drop_table :businesses
  end
end
