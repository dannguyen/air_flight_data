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
  
  it "should have :shortname" do 
    @airline = FactoryGirl.create(:airline, :name=>"United Airlines")
    @airline.shortname.must_equal('United')
    
    
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
    @airline = FactoryGirl.create(:airline)

    @airports = 6.times.map do |i| 
      airport = FactoryGirl.create(:airport)
      FactoryGirl.create(:ontime_record, :airport=>airport, :airline=>@airline, :arrivals=>100 * (i+1) )
      airport
    end
    # last airport has most arrivals


    @top_airport_aggs = @airline.top_airports_with_arrivals(:limit=>3)
    @top_airport_aggs.length.must_equal 3

    @top_airport = @top_airport_aggs.first.airport
    @top_airport.must_be_kind_of Airport


    @top_airport_aggs.last.airport.must_equal @airports.reverse[2]
    #alternatively:
    @top_airport_aggs.to_a.map{|a| a.airport_id}.must_equal @airports.sort_by{|a| a.ontime_records.arrivals }.reverse.map{|a| a.id}[0..2]

  end
  
  
end
