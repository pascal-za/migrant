class ChangedChameleonsRenamedOldSpots < ActiveRecord::Migration
  def self.up
    rename_column :chameleons, :old_spots, :new_spots
  end
  
  def self.down
    rename_column :chameleons, :new_spots, :old_spots
  end
end
