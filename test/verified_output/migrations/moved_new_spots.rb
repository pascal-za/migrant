class ChangedChameleonsAddedNewIntegerySpotsAndMovedNewSpots < ActiveRecord::Migration
  def self.up
    add_column :chameleons, :new_integery_spots, :integer
    puts "-- copy data from :new_spots to :new_integery_spots"
    Chameleon.update_all("new_integery_spots = new_spots")
    remove_column :chameleons, :new_spots
  end
  
  def self.down
    add_column :chameleons, :new_spots, :string, :limit=>255
    puts "-- copy data from :new_integery_spots to :new_spots"    
    Chameleon.update_all("new_spots = new_integery_spots")
    remove_column :chameleons, :new_integery_spots
  end
end
