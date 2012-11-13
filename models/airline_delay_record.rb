class AirlineDelayRecord < ActiveRecord::Base

	belongs_to :airline
	belongs_to :airport

	delegate :name, :to=>:airport, :prefix=>true
	delegate :name, :to=>:airline, :prefix=>true
	before_save :hook_into_airport_airline


	private

	def hook_into_airport_airline
		self.airline = Airline.find_by_iata_code(self.airline_code)
		self.airport = Airport.find_by_code(self.airport_code)
	end
end
