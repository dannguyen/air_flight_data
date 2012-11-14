require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

describe "OntimeRecord Model" do
  before do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
  end
  
  
  it 'can construct a new instance' do
    @ontime_report = OntimeRecord.new
    refute_nil @ontime_report
  end
  
  it 'factory' do
    ontime_report = FactoryGirl.build(:ontime_record)
    ontime_report.wont_be_nil
  end
  
  
  it "should have named_scope of by_airport" do 
    @airport1 = FactoryGirl.create(:airport_with_ontime_records, rec_count: 7)
    @airport2 = FactoryGirl.create(:airport_with_ontime_records, rec_count: 3)
    
    OntimeRecord.by_airport(@airport1).count.must_equal 7
    OntimeRecord.by_airport(@airport1).arrivals_count.must_equal @airport1.ontime_records.arrivals_count
    
    # should accept airport code as well
    
    OntimeRecord.by_airport(@airport2.code).count.must_equal 3
    
  end
  
  it "should have named_scope of by_airline" do 
  
    @a1 = FactoryGirl.create(:airline_with_ontime_records, rec_count: 3)
    @a2 = FactoryGirl.create(:airline_with_ontime_records, rec_count: 7)
    

    OntimeRecord.by_airline(@a1).count.must_equal 3
    OntimeRecord.by_airline(@a1).arrivals_count.must_equal @a1.ontime_records.arrivals_count
    
    # should accept iata_code  as well
    
    OntimeRecord.by_airline(@a2.iata_code).count.must_equal 7
  
  end

  it "should have named_scope of by_year and by_month" do 
    
    FactoryGirl.create_list(:ontime_record, 8, :month=>8, :year=>2010)
    FactoryGirl.create_list(:ontime_record, 3, :month=>3, :year=>2011)
    
    OntimeRecord.by_year(2010).count.must_equal 8
    OntimeRecord.by_month(3).count.must_equal 3
    
  end

  
  it ":arrivals_count should sum the number of arrivals" do
    arr =  [100, 500, 600, 700, 200]

    arr.each{|val| ontime_report = FactoryGirl.create(:ontime_record, {arr_flights: val}) }    
    OntimeRecord.arrivals_count.must_equal arr.inject(0){|s,v| s += v}
  
  end
  

  it ":delayed_arrivals_count should sum the number of arrivals" do
    
    arr = [10, 20, 30]
    arr.each{|val| ontime_report = FactoryGirl.create(:ontime_record, {arr_del15: val}) }    
    
    OntimeRecord.delayed_arrivals_count.must_equal 60
  end
  
  it ":delayed_arrivals_rate should average the number of delayed over arrivals" do
    pct = 0.2
    arr =  [100, 500, 600, 700, 200]
    
    arr.each{|val| ontime_report = FactoryGirl.create(:ontime_record, {arr_flights: val, arr_del15: val*pct }) }    
    OntimeRecord.delayed_arrivals_rate.must_equal pct  
  end
  
end
