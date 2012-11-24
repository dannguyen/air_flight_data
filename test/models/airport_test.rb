require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

describe "Airport Model" do
  before do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
  end
  
  
  
  it "can build" do 
    airport = FactoryGirl.build(:airport)
    airport.wont_be_nil
  end
  
  it "can find nearest airports" do 
    
    lats = [30, 30.0001, 30.0002, -40]
    airports = lats.map{|lat| FactoryGirl.create(:airport, {:latitude=>lat, :longitude=>100} )}
    a = airports.first
    
    nearbies = a.nearbys(100)
    nearbies.length.must_equal 2
    nearbies.first.must_equal airports[1]
  end
  
  it "should find similar airports" do 
    
    lats = [30, 30.0001, 30.0002, -40, 80]
    airports = lats.map{|lat| FactoryGirl.create(:airport, {:latitude=>lat, :longitude=>100} )}
    simports = Airport.similar_to(airports.first, 3)
    
    simports.length.must_equal 3 #stub method
    airports.first.similar_airports(3).must_equal simports
    
  end
  
  it "should atually find similar airports" do 
    skip
    raise "implement something here"
  end
  


  
end
