require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

describe "OntimeRecord Instances" do
  before do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
  end
  
  it "should have year_month attribute" do 
    @r = FactoryGirl.create(:ontime_record, month: 7, year: 2012)
    @r.year_month.must_equal "2012-07"
  end

  it "should have arrivals as an alias" do 
    a = 200
    @r = FactoryGirl.create(:ontime_record, arr_flights: a)
    @r.arrivals.must_equal a 

  end

  it "should have delayed_arrivals as an alias" do 
    b = 100
    @r = FactoryGirl.create(:ontime_record, arr_del15: b)
    @r.delayed_arrivals.must_equal b
  end


  
  it "should have carrier_delayed_arrivals as an alias" do 
    c = 20
    @r = FactoryGirl.create(:ontime_record, carrier_ct: c)
    @r.carrier_delayed_arrivals.must_equal c
  end
  
  it "should have pct of delayed flights" do 
    a = 200
    b = 100

    @r = FactoryGirl.create(:ontime_record, arr_flights: a, arr_del15: b)

    @r.delayed_arrivals_rate.must_equal b.to_f/a

  end

  it "should have :other_causes_delayed_arrivals include security and late_aircraft" do
    c = 42
    d = 99

    @r = FactoryGirl.create(:ontime_record, :security_delayed_arrivals=>c, :late_aircraft_delayed_arrivals=>d)
    
    @r.other_causes_delayed_arrivals.must_equal(c + d)

  end


  it "should have pct of carrier-fault flights" do 
    a = 200
    b = 100
    c = 20

    @r = FactoryGirl.create(:ontime_record, arr_flights: a, arr_del15: b, carrier_ct: c)

    @r.carrier_delayed_arrivals_rate.must_equal c.to_f/a
  end


  it "should respond to delayed_arrivals suite of aliased methods, and have auto-meta-gen 'rates'" do 

    @r = FactoryGirl.create(:ontime_record)

    OntimeRecord.delayed_arrivals_causes_methods_suite.each do |dmeth|
      dmeth.to_s.must_be :=~, /delayed_arrivals$/
      @r.must_respond_to dmeth

      dmeth_rate = "#{dmeth}_rate".to_sym
      @r.must_respond_to dmeth_rate
    end

  end



end
