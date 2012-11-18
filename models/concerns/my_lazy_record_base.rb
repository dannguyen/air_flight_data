module MyLazyRecordBase
  extend ActiveSupport::Concern
  
  included do
    def self.self_re
       self.scoped
#      return self.kind_of?(ActiveRecord::Relation) ? self : self.scoped
    end
  end



  def date_int
   foo_on_record_date_int(self)
  end
  
end


module MyFoos
  


  def foo_to_year_month(yr,mth)
    "#{yr}-#{"%02d" % mth}"
  end
  
  def foo_to_date_int(y,m,d=0)
   (("%04d" % y) + ("%02d" % m ) + ("%02d" % d )).to_i #{"%02d" % day}".to_i
  end

  def foo_on_record_date_int(ar)
    y = ar.attribute_present?(:year) ? ar.year : 0
   m = ar.attribute_present?(:month) ? ar.month : 0
   d = ar.attribute_present?(:day) ? ar.day : 0
  
   foo_to_date_int(y,m,d)
  end

end

include MyFoos