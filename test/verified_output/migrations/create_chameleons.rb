class CreateChameleons < ActiveRecord::Migration
  def self.up
    create_table :chameleons do |t|
      t.string :spots
    end
  end

  def self.down
    drop_table :chameleons
  end
end
