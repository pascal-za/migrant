class ChangedChameleonsAddedIncompatibleSpotAndDeletedSpots < ActiveRecord::Migration
  def self.up
    add_column :chameleons, :incompatible_spot, :integer
    remove_column :chameleons, :spots
  end
  
  def self.down
    add_column :chameleons, :spots, :string, :limit=>255
    remove_column :chameleons, :incompatible_spot
  end
end
