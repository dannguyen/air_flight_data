class AirportDatum < ActiveRecord::Base

	belongs_to :airport
	

	delegate :name, :to=>:airport, :prefix=>true, :allow_nil=>true
	before_validation :hook_into_airport



    private
    
  	def hook_into_airport
  		self.airport = Airport.find_by_code(self.airport_code)
  	end
  	
end
