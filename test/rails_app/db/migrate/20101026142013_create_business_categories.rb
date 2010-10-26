class CreateBusinessCategories < ActiveRecord::Migration
  def self.up
    create_table :business_categories do |t|
      t.integer :business_id
      t.integer :category_id
    end
    add_index :business_categories, :business_id
    add_index :business_categories, :category_id
  end
  
  def self.down
    drop_table :business_categories
  end
end