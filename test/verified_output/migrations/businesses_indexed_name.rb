class ChangedBusinessesIndexedName < ActiveRecord::Migration
  def self.up
    add_index :businesses, :name
  end

  def self.down
  end
end
