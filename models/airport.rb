class Airport < ActiveRecord::Base
	extend FriendlyId
	validates_uniqueness_of :code
   friendly_id :code, use: :slugged

   has_many :airline_delay_records


  def normalize_friendly_id(string)
    super.upcase
  end
end
