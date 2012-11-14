class Airline < ActiveRecord::Base
	extend FriendlyId
	validates_uniqueness_of [:iata_code, :icao_code]

   friendly_id :name, use: :slugged

   has_many :airline_delay_records
   
   
   scope :similar_to, lambda{|r, num|  where('id != ?', r.id).limit(num) } # TK


   def normalize_friendly_id(string)
     super.upcase
   end

   def similar_airlines(num)
     self.class.similar_to(self, num)
   end
   
   
   
   def arrivals_at_airport(c)
     records_at_airport(c).arrivals_sum
   end

   def delayed_arrivals_at_airport(c)
     records_at_airport(c).all_delayed_arrivals_sum
   end

   def delayed_arrivals_at_airport_by_own_fault(c)
     records_at_airport(c).all_delayed_arrivals_sum.airline_delayed_arrivals_sum
   end
   
   
   def airports_by_arrivals_sum
    airline_delay_records.airports_by_arrivals_sum
   end


   private 
  
   def records_at_airport(c)
      airline_delay_records.by_airport(c)
   end
end


