class CreateOntimeReports < ActiveRecord::Migration
  def self.up
    create_table :ontime_reports do |t|
      
      t.timestamps
    end
  end

  def self.down
    drop_table :ontime_reports
  end
end
