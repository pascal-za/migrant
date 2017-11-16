class ChangedBusinessesModifiedVerifiedDefaultedToTrue < ActiveRecord::Migration
  def self.up
    change_column :businesses, :verified, :boolean, :default=>true
  end
  
  def self.down
    change_column :businesses, :verified, :boolean, :limit=>nil, :default=>"f"
  end
end
