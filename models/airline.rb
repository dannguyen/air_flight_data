class Airline < ActiveRecord::Base
	extend FriendlyId
	include MyLazyRecordBase
#  CANONICAL_CODES = %w(AA MQ FL OH DL F9 B6 NW WN UA US)
   CANONICAL_CODES = %w(AA DL MQ NW WN B6 UA US)
	validates_uniqueness_of [:iata_code, :icao_code]

   friendly_id :name, use: :slugged

   has_many :ontime_records
   
   
   scope :similar_to, lambda{|r, num|  where('id != ?', r.id).limit(num) } # TK

   scope :canonical, where(:iata_code=>CANONICAL_CODES)
   
   def Airline.canonical_ids
     self.canonical.map{|a| a.id}
   end
   
   
   def shortname
     name.sub(/ *Airlines?/, '')
   end


   def similar_airlines(num)
     self.class.similar_to(self, num)
   end
   
   def top_airports_with_arrivals(opts={}) 
    # returns airports in order of arrivals, with
    
      
    opts = opts.merge({:order=>"arrivals DESC"}) 
    self.ontime_records.group_and_sum_by(:airport_id, opts)
   end


### untested   
   def arrivals_at_airport(c)
     records_at_airport(c).arrivals_sum
   end

   def delayed_arrivals_at_airport(c)
     records_at_airport(c).all_delayed_arrivals_sum
   end

   def delayed_arrivals_at_airport_by_own_fault(c)
     records_at_airport(c).all_delayed_arrivals_sum.ontimeed_arrivals_sum
   end
   
   
   def airports_by_arrivals_sum
    ontime_records.airports_by_arrivals_sum
   end


   private 
  
   def records_at_airport(c)
      ontime_records.by_airport(c)
   end
end


