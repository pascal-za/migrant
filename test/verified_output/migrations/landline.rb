class ChangedBusinessesModifiedLandline < ActiveRecord::Migration
  def self.up
    change_column :businesses, :landline, :text
  end
  
  def self.down
    change_column :businesses, :landline, :string, :limit=>255
  end
end
