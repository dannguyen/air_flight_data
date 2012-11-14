# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 3) do

  create_table "airline_delay_records", :force => true do |t|
    t.integer  "airline_id"
    t.integer  "airport_id"
    t.string   "airport_full_name"
    t.integer  "year"
    t.integer  "month"
    t.string   "airline_code"
    t.string   "carrier_name"
    t.string   "airport_code"
    t.string   "airport_name"
    t.integer  "arr_flights"
    t.integer  "arr_del15"
    t.float    "carrier_ct"
    t.float    "weather_ct"
    t.float    "nas_ct"
    t.float    "security_ct"
    t.float    "late_aircraft_ct"
    t.integer  "arr_cancelled"
    t.integer  "arr_diverted"
    t.integer  "arr_delay"
    t.integer  "carrier_delay"
    t.integer  "weather_delay"
    t.integer  "nas_delay"
    t.integer  "security_delay"
    t.integer  "late_aircraft_delay"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "airlines", :force => true do |t|
    t.string "iata_code", :length=>2
    t.string "icao_code", :length=>3
    t.string "name"
    t.string "call_sign"
    t.string "country"
    t.string "slug"

    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "airports", :force => true do |t|
    t.string "code"
    t.string "name"
    t.string "region"
    t.string "state"
    t.string "county"
    t.string "country", :default=>"U.S."
    t.string "city"
    t.string "slug"
    t.string "site_number", :length=>5
    t.float  "latitude"
    t.float  "longitude"
    
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "airport_data", :force=> true do |t|
    t.integer "year"
    t.integer "month"
    t.integer "enplanements"
    t.string  "airport_code"
    t.integer "airport_id"
  end

  add_index :airports, :slug, unique: true
  add_index :airports, :code, unique: true
  add_index :airlines, :slug, unique: true

  add_index :airline_delay_records, :year
  add_index :airline_delay_records, :airport_id
  add_index :airline_delay_records, :airline_id

end
