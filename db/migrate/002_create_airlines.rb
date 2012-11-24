class CreateAirlines < ActiveRecord::Migration
  def self.up
    create_table :airlines do |t|
      
      t.timestamps
    end
  end

  def self.down
    drop_table :airlines
  end
end
