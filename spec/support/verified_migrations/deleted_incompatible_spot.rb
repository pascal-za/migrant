class ChangedChameleonsDeletedIncompatibleSpot < ActiveRecord::Migration
  def self.up
    remove_column :chameleons, :incompatible_spot
  end
  
  def self.down
    add_column :chameleons, :incompatible_spot, :integer, :limit=>nil
  end
end
