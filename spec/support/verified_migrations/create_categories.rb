class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.string :title
      t.string :summary
    end
    add_index :categories, :title
  end
  
  def self.down
    drop_table :categories
  end
end
