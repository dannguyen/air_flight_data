module MyLazyRecordBase
  extend ActiveSupport::Concern
  
  included do
    def self.self_re
       self.scoped
#      return self.kind_of?(ActiveRecord::Relation) ? self : self.scoped
    end
  end
  
end