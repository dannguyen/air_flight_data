class CreateAirlineDelayReports < ActiveRecord::Migration
  def self.up
    create_table :airline_delay_reports do |t|
      
      t.timestamps
    end
  end

  def self.down
    drop_table :airline_delay_reports
  end
end
