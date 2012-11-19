require 'ostruct'
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


  alias_attribute :arrivals , :arr_flights

  ARRIVAL_STAT_COUNT_NAME_MAPPING = {
    :arr_del15=>:delayed_arrivals, 
    :carrier_ct=>:carrier_delayed_arrivals, 
    :weather_ct=>:weather_delayed_arrivals, 
    :nas_ct=>:nas_delayed_arrivals, 
    :security_ct=>:security_delayed_arrivals, 
    :late_aircraft_ct=>:late_aircraft_delayed_arrivals
  }

  ARRIVAL_STAT_COUNT_NAME_MAPPING.each_pair do |a,b|
    alias_attribute b, a
  end
  
  
  def OntimeRecord.delayed_arrivals_methods_suite
    ARRIVAL_STAT_COUNT_NAME_MAPPING.values
  end

  def OntimeRecord.delayed_arrivals_causes_methods_suite 
    # all the methods that compose the attributes that make up :delayed_arrivals
    self.delayed_arrivals_methods_suite - [:delayed_arrivals]
  end

  def OntimeRecord.delayed_arrivals_causes_rate_methods_suite
    self.delayed_arrivals_causes_methods_suite.map{|m| "#{m}_rate".to_sym}
  end


  def other_causes_delayed_arrivals
    security_delayed_arrivals + late_aircraft_delayed_arrivals
  end


	def year_month
	  foo_to_year_month(year, month)
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


  OntimeRecord.delayed_arrivals_methods_suite.each do |mth|
    
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
  

  def self.earliest_period
    if a = self_re.min_by{|b| b.year_month}
      yr, mth = a.year_month.split('-', 3).map{|x| x.to_i}
      return {
       :year_month => a.year_month,
       :year=>yr,
       :month=>mth
      }
    end
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
    # returns a hsh, hsh[:periods] is a two-element array
    
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


  def self.group_and_sum_by(facets, opts={})
    # returns an array of ActiveRelation-like openstruct
    facets_for_group_by = Array(facets)
    the_reflection = self_re


    # define options
    do_rounding = opts.delete :round
    _eager_loading = (opts.delete(:eager_load) != false) # eager load by default
    _order = opts.delete(:order)
    _limit = opts.delete(:limit)


    ### define SELECT

    select_arr = ["SUM(arr_flights) AS arrivals"]

    select_arr += facets_for_group_by # standard attributes

    ARRIVAL_STAT_COUNT_NAME_MAPPING.each_pair do |k,v|
      # delayed_arrivals  --> SUM(arr_del15)
      select_arr << "SUM(#{k}) AS `#{v}`"
    end


    group_value_fields = ARRIVAL_STAT_COUNT_NAME_MAPPING.values


    the_reflection = the_reflection.select(select_arr.join(', ')).group(facets_for_group_by)

    # if relations are active, put them in separate array for differed handling;
    # e.g. add _id and eager loading


    # e.g. airline_id to :airline
    facets_for_includes = (facets_for_group_by & [:airline_id, :airport_id]).map{|f| f.to_s.sub(/_id$/, '').to_sym }
    
    if _eager_loading && !facets_for_includes.empty?
      the_reflection = the_reflection.includes(facets_for_includes)
    end

    if _order
      the_reflection = the_reflection.order(_order)
    end

    if _limit
      the_reflection = the_reflection.limit(_limit)
    end


    # do the query
    results = the_reflection.to_a


    results_arr = results.map do |result|
     
          hsh = result.attributes.inject({}){|h,(k,v)| h[k.to_sym] = v; h}     

          hsh[:date_int] = foo_on_record_date_int(result)
          hsh[:date_epoch_sec] = foo_on_record_epoch_sec(result) # ugh...
          if _eager_loading
            # include airport, airline if exists
            facets_for_includes.each{ |_f| hsh[_f] = result.send(_f) }
          end

        # set cumulative rate methods
          group_value_fields.each do |foo|
            rate_foo = "#{foo}_rate".to_sym
            hsh[rate_foo] = hsh[foo].to_f/hsh[:arrivals] 
            hsh[rate_foo] = hsh[rate_foo].round(do_rounding) unless do_rounding.nil? 
          end
        
          OpenStruct.new(hsh)
     end 

     return results_arr


  end


  def self.group_and_sum_by_airports(opts={})
    self.group_and_sum_by(:airport_id, opts.merge({:order=>"arrivals DESC"}))
  end

  def self.monthly_group_sums(opts={})
    self.group_and_sum_by(:month, opts.merge({:order=>'month'}))
  end


  def self.yearly_group_sums(opts={})
    self.group_and_sum_by(:year, opts.merge({:order=>'year'} ))
  end

  def self.yoy_monthly_group_sums(mnth, opts={})
    self.by_month(mnth).yearly_group_sums opts.merge({:order=>'year'})
  end


  # convenience method for airlines

  def self.all_airline_group_sums_over_time(opts={})
    opts = opts.merge({:order=>"year ASC, month ASC"  })
    self.group_and_sum_by([:month, :year, :airline_id], opts)
  end


  ## NOT SCOPED METHODS

  def OntimeRecord.format_group_sum_for_time_series(records, facet_class=:airline, att=:carrier_delayed_arrivals_rate)
    # this is for the carrier-caused time series


    # accepts: OntimeRecord hash
    # returns: Hash in the form of:
    
# {    
#   data_groups: { 
#     entity: facet_class,
#      data: [{x:1, y:2},{x:1, y:2},{x:1, y:2}]
#   }, 
#  time_range: [x,y]
# }


    # NOTE: This does the group and sum method, not just formatting

    record_aggs = records.all_airline_group_sums_over_time

    ## get entities




    data_grps = record_aggs.inject( Hash.new{|h,k| h[k] = { :data=>[] }  }   ) do |hsh, agg|

      entity = agg.send(facet_class)

      hsh[entity.id][:data] <<  {x: agg.date_int, y: agg.send(att)}
      hsh[entity.id][:entity] ||= entity
      hsh

    end

    time_range = record_aggs.minmax_by{|a| a.date_int}


    return {:time_range=>time_range, :data_groups=> data_grps.values} # each value is a hash containing :entity and :data
  end



def OntimeRecord.format_group_sum_for_delay_causes_stacked_chart(record_aggs)
    # accepts array of struct
    # expects year, month in each object, and for hings to be in order
   
    raise ArgumentError, "We need an array here" unless record_aggs.class == Array
  

    rec_foos = OntimeRecord.delayed_arrivals_causes_rate_methods_suite
    
    series = rec_foos.map do |foo|

      {
        :name => foo,
        :data => record_aggs.map{|r| {x: r.date_epoch_sec, y: r.send(foo) } }
      }
    end

    return { :series=>series }
              
  end











  def OntimeRecord.deprecated_format_group_sum_for_delay_causes_stacked_chart(record_aggs)
    # accepts array of struct
    # expects year, month in each object, and for hings to be in order
    
    # returns Hash
    #  { x: ["2009-09", "2009-10"] ,  y: [[1,2,3,4], [9,8,7,6]], 
    #    layers: [{:name=>'carrier_cause', :name=>"something"}]
    #  }
    #
    #
    #
  
    xes  = []
    yes = []
   

    rec_meths = OntimeRecord.delayed_arrivals_causes_rate_methods_suite
    
     layers = rec_meths.map{|m| {:name=>m} }


    record_aggs[0..100].each_with_index do |agg, idx|
      
      xes <<  idx #foo_to_year_month(agg.year, agg.month).gsub(/[^\d]/, '').to_i
      yes <<  rec_meths.map{|mth| agg.send(mth)}        
    end


    return { :data=> {x: xes, y: yes},  :layers=>layers }
              
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