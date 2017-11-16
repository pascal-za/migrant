class ChangedChameleonsAddedIncompatibleSpotAndDeletedNewLongerSpots < ActiveRecord::Migration
  def self.up
    add_column :chameleons, :incompatible_spot, :integer
    remove_column :chameleons, :new_longer_spots
  end
  
  def self.down
    add_column :chameleons, :new_longer_spots, :text, :limit=>nil
    remove_column :chameleons, :incompatible_spot
  end
end
