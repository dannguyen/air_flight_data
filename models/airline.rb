class Airline < ActiveRecord::Base
	extend FriendlyId
	validates_uniqueness_of [:iata_code, :icao_code]

   friendly_id :name, use: :slugged

   has_many :airline_delay_records

end
