class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :encrypted_password, :limit=>48
      t.string :password_salt, :limit=>42
      t.decimal :money_spent, :precision=>10, :scale=>2
      t.decimal :money_gifted, :precision=>10, :scale=>2
      t.double :average_rating
    end
    
  end
  
  def self.down
    drop_table :users
  end
end