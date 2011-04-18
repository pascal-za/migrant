class ChangedChameleonsDeletedSpots < ActiveRecord::Migration
  def self.up
    remove_column :chameleons, :spots
  end

  def self.down
    add_column :chameleons, :spots, :string, :limit=>255
  end
end
