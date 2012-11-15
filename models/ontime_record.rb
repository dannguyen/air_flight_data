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

  scope :by_airline, lambda{ |cd| 
    c = (cd.is_a?Airline) ? cd.iata_code : cd 
    includes(:airline).where('airlines.iata_code'=>c)}

  
  scope :by_airport, lambda{ |cd| 
    c = (cd.is_a?Airport) ? cd.code : cd 
    includes(:airport).where('airports.code'=>c)}

  validates_presence_of :airport_id
  validates_presence_of :airline_id

	def year_month
	  "#{year}-#{"%02d" % month}"
  end
	
	
	
	def self.arrivals_count
	  self.sum(&:arr_flights)
  end
  
  def self.delayed_arrivals_count
    self.sum(&:arr_del15)
  end
  
  def self.delayed_arrivals_rate
    self.delayed_arrivals_count.to_f / self.arrivals_count 
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
  
  

  def self.compare_periods(opts={})
    # default is year-over-year, latest period
    hsh = {:periods=>[]}
    hsh[:period_type] = opts[:period_type] || 'YOY'    
    _period = self.latest_period
    
    _prev_year_month = "#{_period[:year]-1}-#{"%02d" % _period[:month]}"
    

    hsh[:periods] << {
      :name=>_prev_year_month,
      :records=>self.by_year_month(_prev_year_month)
    }

    
    hsh[:periods] << {
      :name=>_period[:year_month],
      :records=>self.by_year_month(_period[:year_month])
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
