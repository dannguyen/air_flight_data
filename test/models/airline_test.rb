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
  
  
end
