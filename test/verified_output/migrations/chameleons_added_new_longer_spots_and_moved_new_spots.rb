class ChangedChameleonsAddedNewLongerSpotsAndMovedNewSpots < ActiveRecord::Migration
  def self.up
    add_column :chameleons, :new_longer_spots, :text
    puts "-- copy data from :new_spots to :new_longer_spots"
    Chameleon.update_all("new_longer_spots = new_spots")
    remove_column :chameleons, :new_spots
  end
  
  def self.down
    add_column :chameleons, :new_spots, :string, :limit=>255
    puts "-- copy data from :new_longer_spots to :new_spots"    
    Chameleon.update_all("new_spots = new_longer_spots")
    remove_column :chameleons, :new_longer_spots
  end
end
