SkiftAir.helpers do 
  
  def format_records_agg_for_delay_causes_stacked_chart(record_aggs)
    # accepts array of struct
    # expects year, month in each object
    
    # returns parsed json:
    #  { x: ["2009-09", "2009-10"] ,  y: [[1,2,3,4], [9,8,7,6]], 
    #    layers: [{:name=>'carrier_cause', :name=>"something"}]
    #  }
    #
    #
    #
    raise "hey there"
    hsh = { 
      x:[], 
      y:[], layers: []}
    
    
    record_aggs.each() do |hsh|
      
      
    end
    
  end
end