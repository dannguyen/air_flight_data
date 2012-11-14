require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

describe "AirlineDelayRecord Model" do
  before do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
  end
  
  
  it 'can construct a new instance' do
    @airline_delay_report = AirlineDelayRecord.new
    refute_nil @airline_delay_report
  end
  
  it 'factory' do
    delay_report = FactoryGirl.build(:airline_delay_record)
    delay_report.wont_be_nil
  end
  
  
  it "should have named_scope of by_airport" do 
    @airport1 = FactoryGirl.create(:airport_with_delays, delays_count: 7)
    @airport2 = FactoryGirl.create(:airport_with_delays, delays_count: 3)
    
    AirlineDelayRecord.by_airport(@airport1).count.must_equal 7
    AirlineDelayRecord.by_airport(@airport1).arrivals_count.must_equal @airport1.airline_delay_records.arrivals_count
    
    # should accept airport code as well
    
    AirlineDelayRecord.by_airport(@airport1.code).count.must_equal 7
    
    
  end
  
  
  it ":arrivals_count should sum the number of arrivals" do
    arr =  [100, 500, 600, 700, 200]

    arr.each{|val| delay_report = FactoryGirl.create(:airline_delay_record, {arr_flights: val}) }    
    AirlineDelayRecord.arrivals_count.must_equal arr.inject(0){|s,v| s += v}
  
  end
  

  it ":delayed_arrivals_count should sum the number of arrivals" do
    
    arr = [10, 20, 30]
    arr.each{|val| delay_report = FactoryGirl.create(:airline_delay_record, {arr_del15: val}) }    
    
    AirlineDelayRecord.delayed_arrivals_count.must_equal 60
  end
  
  it ":delayed_arrivals_rate should sum the number of arrivals" do
    pct = 0.2
    arr =  [100, 500, 600, 700, 200]
    
    arr.each{|val| delay_report = FactoryGirl.create(:airline_delay_record, {arr_flights: val, arr_del15: val*pct }) }    
    AirlineDelayRecord.delayed_arrivals_rate.must_equal pct
  
  end
  
end
