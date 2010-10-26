class BusinessesModifyFieldsEstimatedValueNotes < ActiveRecord::Migration
  def self.up
    add_column :businesses, :estimated_value, :float
    add_column :businesses, :notes, :string
  end
  
  def self.down
    remove_column :businesses, :estimated_value
    remove_column :businesses, :notes
  end
end
