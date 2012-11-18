class Airline < ActiveRecord::Base
	extend FriendlyId
	include MyLazyRecordBase
  
	validates_uniqueness_of [:iata_code, :icao_code]

   friendly_id :name, use: :slugged

   has_many :ontime_records
   
   
   scope :similar_to, lambda{|r, num|  where('id != ?', r.id).limit(num) } # TK



   def similar_airlines(num)
     self.class.similar_to(self, num)
   end
   
   def top_airports(num) # by arrivals, TK
    self.ontime_records.group_and_sum(:airport, :find_models=>true, :order=>"arrivals DESC", :limit=>num)


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


