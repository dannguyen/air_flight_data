module MyLazyRecordBase
  extend ActiveSupport::Concern
  
  included do
    def self.self_re
       self.scoped
#      return self.kind_of?(ActiveRecord::Relation) ? self : self.scoped
    end
    
    def self.get_uniq(args)
      facets = Array(args).flatten
      
      uniq_val_records = self_re.select(facets).uniq
      
      if facets.length == 1
          foo = facets.first
          collection = uniq_val_records.map{|k| k.send(foo)} # Array
      elsif args.is_a?(Array)
        collection = facets.inject({}) do |hsh, foo|
          hsh[foo] = uniq_val_records.map{|v| v.send(foo)}.uniq
          hsh
        end  
      
      elsif args.is_a?(Hash) && facets.length == 2
          # for now, only dealing with things like {:year=>:month}
          
          key_foo, val_foo = facets
          keys = uniq_val_records.map{|k| k.send(key_foo)}.uniq
          # e.g. [2010, 2011]
          
          # result: {2010=>{1,2,3,4,5}, 2011=>{1,2,3}}
          collection = keys.inject({}) do |hsh, key|
            hsh[key] = uniq_val_records.select{|u| u.send(key_foo) == key}.map{|u| u.send(val_foo) }.uniq
            hsh
          end
      else
        raise ArgumentError          
      end
      
      return collection
      
      
    end
  end



  def date_int
   foo_on_record_date_int(self)
  end
  
  
  
  
#  def date_epoch_sec
 #  foo_on_record_epoch_sec(self)
 # end



end


module MyFoos
  

  def foo_get_date_components_arr(ar)
   return [
      ar.attribute_present?(:year) ? ar.year : 0,
      ar.attribute_present?(:month) ? ar.month : 0,
      ar.attribute_present?(:day) ? ar.day : 0
    ]
  end

  def foo_to_year_month(yr,mth)
    "#{yr}-#{"%02d" % mth}"
  end
  
  def foo_to_date_int(y,m,d=0)
   (("%04d" % y) + ("%02d" % m ) + ("%02d" % d )).to_i #{"%02d" % day}".to_i
  end

  def foo_on_record_date_int(ar)
   arr = foo_get_date_components_arr(ar)  
   foo_to_date_int(*arr)
  end

  def foo_on_record_epoch_sec(ar)
   if ar.attribute_present?(:year) && ar.attribute_present?(:month) 
      yr = ar.year
      mth = ar.month

      day = ar.attribute_present?(:day) ? ar.day : 1

      return Date.new(yr, mth, day).to_time.to_i
   end
  end


end

include MyFoos