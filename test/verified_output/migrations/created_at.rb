class ChangedBusinessesAddedUpdatedAtCreatedAt < ActiveRecord::Migration
  def self.up
    add_column :businesses, :updated_at, :datetime
    add_column :businesses, :created_at, :datetime
  end
  
  def self.down
    remove_column :businesses, :updated_at
    remove_column :businesses, :created_at
  end
end
