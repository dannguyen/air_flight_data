class OntimeRecord < ActiveRecord::Base

  include MyLazyRecordBase
	belongs_to :airline
	belongs_to :airport

	delegate :name, :to=>:airport, :prefix=>true, :allow_nil=>true
	delegate :name, :to=>:airline, :prefix=>true
	before_validation :hook_into_airport_airline

  scope :top, where("arr_flights > ?", 100)
  scope :christmas, where(:month=>12)
  scope :by_year, lambda{|yr| where(:year=>yr)}
  scope :by_month, lambda{|m| where(:month=>m)}
  scope :by_year_month, lambda{|str| yr,mth = str.split('-'); by_year(yr).by_month(mth)}

  scope :by_ytd, lambda{|str|  
    yr,mth = str.split('-',3)
    where(:year=>yr.to_i, :month=>(1..mth.to_i))  
  }

  scope :by_airline, lambda{ |cd| 
    c = (cd.is_a?Airline) ? cd.iata_code : cd 
    includes(:airline).where('airlines.iata_code'=>c)}

  
  scope :by_airport, lambda{ |cd| 
    c = (cd.is_a?Airport) ? cd.code : cd 
    includes(:airport).where('airports.code'=>c)}

  validates_presence_of :airport_id
  validates_presence_of :airline_id
  validates_presence_of :arr_flights

  alias_attribute :arrivals, :arr_flights 
  alias_attribute :delayed_arrivals, :arr_del15
  alias_attribute :carrier_delayed_arrivals, :carrier_ct
  alias_attribute :weather_delayed_arrivals, :weather_ct
  alias_attribute :nas_delayed_arrivals, :nas_ct
  alias_attribute :security_delayed_arrivals, :security_ct
  alias_attribute :late_aircraft_delayed_arrivals, :late_aircraft_ct


  def other_causes_delayed_arrivals
    security_delayed_arrivals + late_aircraft_delayed_arrivals
  end


	def year_month
	  foo_to_year_month(year, month)
  end

  def delayed_arrivals_rate
    # this is not part of delayed_arrivals_causes_methods_suite as it is just the general rate
    delayed_arrivals.to_f/arrivals
  end

  def OntimeRecord.delayed_arrivals_causes_methods_suite
    DELAYED_METHODS_CAUSES_ARRIVALS
  end



=begin	


  def carrier_delayed_arrivals_rate
    carrier_delayed_arrivals.to_f/arrivals
  end
=end 
	
=begin 
  ATTRIBUTE_MAP = {
    :year=>'Year',
    :month=>'Month',
    :arrivals=>'Total arrivals',
    :delayed_arrivals=>'Late arrivals (15+ min.)',
    :carrier_delayed_arrivals=>'Carrier fault',
    :weather_delayed_arrivals=>'Extreme weather',
    :nas_delayed_arrivals=>'NAS fault'

}
=end


end


class OntimeRecord < ActiveRecord::Base

## meta methods

 DELAYED_METHODS_CAUSES_ARRIVALS = OntimeRecord.public_instance_methods.select{|m| m.to_s =~ /^[a-z]+\w+_delayed_arrivals$/}

  DELAYED_METHODS_CAUSES_ARRIVALS.each do |mth|
    
   # define class methods
    define_singleton_method(mth) do 
      self_re.sum(&mth)
    end


   # define rate methods
   rate_mth = "#{mth}_rate".to_sym

     define_method(rate_mth) do 
      self.send(mth).to_f / arrivals
    end

    define_singleton_method(rate_mth) do 
      self_re.send(mth).to_f / self.arrivals
    end


   

  end


## meta scope methods




end





class OntimeRecord < ActiveRecord::Base
## scope methods

  def self.arrivals
    self.sum(:arr_flights)
  end
  
  def self.delayed_arrivals
    self.sum(:arr_del15)
  end
  
  def self.delayed_arrivals_rate
    self.delayed_arrivals.to_f / self.arrivals 
  end
  
  def self.latest_period
    if a = self_re.max_by{|b| b.year_month}
      yr, mth = a.year_month.split('-', 3).map{|x| x.to_i}
      return {
       :year_month => a.year_month,
       :year=>yr,
       :month=>mth
      }
    end
  end
  
  
  
  def self.airports_by_arrivals_sum(opts={})
    # returns [[#Airport, 42], ]
    self.includes(:airports).group(:airport_id).hsh_by_arrivals_sum
  end
  
  

  def self.compare_periods(pd_type='YOY', opts={})
    # default is year-over-year, latest period
    unless ['YOY', 'YTD'].index(pd_type)
      raise ArgumentError, "first argument must be 'YOY' or 'YTD', not #{pd_type}"
    end
        
    hsh = {:periods=>[]}
    hsh[:period_type] = pd_type
    
    _late_period = self.latest_period
    
    latest_year = opts[:year] || _late_period[:year]
    latest_month = opts[:month] || _late_period[:month]
    
    latest_year_month = foo_to_year_month(latest_year, latest_month)
    prev_year_month = foo_to_year_month(latest_year-1, latest_month)
    
    scope_name = case hsh[:period_type]    
      when 'YOY'
        :by_year_month
      when 'YTD'
        :by_ytd
      end #case statement
    
      # year-over-year requires a month setting
          
      hsh[:periods] << {
        :name=>prev_year_month,
        :records=>self.send(scope_name, prev_year_month)
      }

    
      hsh[:periods] << {
        :name=>latest_year_month,
        :records=>self.send(scope_name, latest_year_month)
      }
      
        
    
    return hsh
    
#    if opts[:year].blank? || opts[:month].blank?
#    opts[:year] ||= self.latest_period
    
  end


  private


  


# kill
  def self.hsh_by_arrivals_sum
    self.sum(:arr_flights).sort_by{|k,v| v}.reverse.map{|a| [Airport.find(a[0]), a[1]]}
  end


  def hook_into_airport_airline
    self.airline = Airline.find_by_iata_code(self.airline_code) unless self.airline_code.blank?
    self.airport = Airport.find_by_code(self.airport_code) unless self.airport_code.blank?
  end


end