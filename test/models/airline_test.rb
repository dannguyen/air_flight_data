require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

describe "Airline Model" do
  
  before do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
  end
  
  
  it "can build" do 
    airline = FactoryGirl.build(:airline)
    airline.wont_be_nil
  end
  
  it "should find similar airlines" do 
    
    regions = ['a', 'b', 'c', 'd']
    airlines = regions.map{|rgion| FactoryGirl.create(:airline)} #region ignored
    simlines = Airline.similar_to(airlines.first, 3)
    
    simlines.length.must_equal 3 #stub method
    airlines.first.similar_airlines(3).must_equal simlines
    
  end
  
  it "should atually find similar airlines" do 
    skip
    raise "implement something here"
  end

  it "should find top airports" do 
    skip 
    @airline = FactoryGirl.create(:airline)
    @airports = 6.times{ FactoryGirl.create(:airport) }

    @airports.each do |airport|
      FactoryGirl.create(:ontime_record, :airport=>airport, :airline=>@airline)
    end  


    top_airports = @airline.top_airports(3)
    top_airports.length.must_equal 3
    top_airports.to_a.map{|a| a.id}.must_equal @airports.sort_by{|a| a.ontime_records.arrivals }.reverse 



  end
  
  
end
