module MyLazyRecordBase
  extend ActiveSupport::Concern
  
  included do
    def self.self_re
       self.scoped
#      return self.kind_of?(ActiveRecord::Relation) ? self : self.scoped
    end
  end
  
end


module MyFoos
  
  def foo_to_year_month(yr,mth)
    "#{yr}-#{"%02d" % mth}"
  end
  
end

include MyFoos