class AirlineDelayRecord < ActiveRecord::Base

	belongs_to :airline
	belongs_to :airport
	

  

	delegate :name, :to=>:airport, :prefix=>true, :allow_nil=>true
	delegate :name, :to=>:airline, :prefix=>true
	before_save :hook_into_airport_airline

  scope :year, lambda{|yr| where(:year=>yr)}
  scope :by_airport, lambda{ |cd| 
    c = (cd.is_a?Airport) ? cd.code : cd 
    includes(:airport).where('airports.code'=>c)}


	
	def self.arrivals_sum
	  self.sum(:arr_flights)
  end
  
  def self.all_delayed_arrivals_sum
    self.sum(:arr_del15)
  end
  
  def self.airline_delayed_arrivals_sum
    self.sum(:carrier_ct)
  end
  
  def self.airports_by_arrivals_sum(opts={})
    # returns [[#Airport, 42], ]
    self.includes(:airports).group(:airport_id).hsh_by_arrivals_sum
  end
  
  

 
  


	private

  def self.hsh_by_arrivals_sum
    self.sum(:arr_flights).sort_by{|k,v| v}.reverse.map{|a| [Airport.find(a[0]), a[1]]}
  end


	def hook_into_airport_airline
		self.airline = Airline.find_by_iata_code(self.airline_code)
		self.airport = Airport.find_by_code(self.airport_code)
	end

end
