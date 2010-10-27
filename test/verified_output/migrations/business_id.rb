class UsersModifyFieldsBusinessId < ActiveRecord::Migration
  def self.up
    add_column :users, :business_id, :integer
    add_index :users, :business_id
  end
  
  def self.down
    remove_column :users, :business_id
  end
end
