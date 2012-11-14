class Airport < ActiveRecord::Base
	extend FriendlyId
	extend Geocoder::Model::ActiveRecord
  reverse_geocoded_by :latitude, :longitude
  
	
	validates_uniqueness_of :code
   friendly_id :code, use: :slugged

   has_many :ontime_records

   scope :similar_to, lambda{|rport, num|  where('id != ?', rport.id).limit(num) } # TK


  def normalize_friendly_id(string)
    super.upcase
  end
  
  def similar_airports(num)
    self.class.similar_to(self, num)
  end

  
  
  private
	
	
end
