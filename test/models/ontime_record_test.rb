require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

describe "OntimeRecord Scopes" do
  before do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
  end
  
  
  
  it 'factory' do
    ontime_report = FactoryGirl.build(:ontime_record)
    ontime_report.wont_be_nil
  end
  
  it 'should have hack date_int method' do 
    ontime_report = FactoryGirl.build(:ontime_record, :month=>5, :year=>2012)
    ontime_report.date_int.must_equal 20120500
  end
  
  it "should have named_scope of by_airport" do 
    @airport1 = FactoryGirl.create(:airport_with_ontime_records, rec_count: 7)
    @airport2 = FactoryGirl.create(:airport_with_ontime_records, rec_count: 3)
    
    OntimeRecord.by_airport(@airport1).count.must_equal 7
    OntimeRecord.by_airport(@airport1).arrivals.must_equal @airport1.ontime_records.arrivals
    
    # should accept airport code as well
    
    OntimeRecord.by_airport(@airport2.code).count.must_equal 3
    
  end
  
  it "should have :delayed_arrivals_causes_methods_suite that contains a subset of delay methods as a convenience" do 
    OntimeRecord.delayed_arrivals_causes_methods_suite.must_equal OntimeRecord.delayed_arrivals_methods_suite - [:delayed_arrivals]

  end
  
  it "should have by_ytd scope that accepts year-month string" do
    recs = (1..10).map{|i| FactoryGirl.create(:ontime_record, month: i, year: 2012)}
    (1..3).each{|i| FactoryGirl.create(:ontime_record, month: i, year: 2011)}
    
    OntimeRecord.by_ytd('2012-05').arrivals.must_equal(
      OntimeRecord.by_year(2012).where(:month=>1..5).arrivals
    )
    
    OntimeRecord.by_ytd('2012-01').first.must_equal recs.first 
    
  end

  it ":earliest_period should return earliest year and month hash as a scope method" do 
    FactoryGirl.create_list(:ontime_record, 10, :month=>rand(12)+1, :year=>2015)
    @record = FactoryGirl.create(:ontime_record, :month=>12, :year=>2010)
    
    hsh = OntimeRecord.earliest_period
    hsh[:year].must_equal 2010
    hsh[:month].must_equal 12
    hsh[:year_month].must_equal "2010-12"
  end


  
  it ":latest_period should return latest year and month hash as a scope method" do 
    FactoryGirl.create_list(:ontime_record, 10, :month=>rand(12)+1, :year=>2010)
    @record = FactoryGirl.create(:ontime_record, :month=>12, :year=>2015)
    
    hsh = OntimeRecord.latest_period
    hsh[:year].must_equal 2015
    hsh[:month].must_equal 12
    hsh[:year_month].must_equal "2015-12"
  end
  
  
  it ":compare_periods should return records in latest period" do
  
    # these are non-essential
    FactoryGirl.create_list(:ontime_record, 10, :month=>8, :year=>2010)
    
    @airport = FactoryGirl.create(:airport)
    @airline = FactoryGirl.create(:airline)
    
    r_2012 = [ 
      FactoryGirl.create(:ontime_record, :month=>1, :year=>2012, :airport=>@airport, :airline=>@airline),
    FactoryGirl.create(:ontime_record, :month=>2, :year=>2012, :airport=>@airport, :airline=>@airline),
        FactoryGirl.create(:ontime_record, :month=>3, :year=>2012, :airport=>@airport, :airline=>@airline)
    ]

    r_2013 = [
      FactoryGirl.create(:ontime_record, :month=>1, :year=>2013, :airport=>@airport, :airline=>@airline),
    FactoryGirl.create(:ontime_record, :month=>2, :year=>2013, :airport=>@airport, :airline=>@airline),
    FactoryGirl.create(:ontime_record, :month=>3, :year=>2013, :airport=>@airport, :airline=>@airline)
    
    ]
    
    @recs = OntimeRecord.by_airport(@airport).by_airline(@airline)
    @recs.count.must_equal 6 # sanity check
    
    # no arguments, default is YOY, latest year and month
    periods_hsh = @recs.compare_periods
    periods_hsh[:period_type].must_equal 'YOY'
    
    periods = periods_hsh[:periods]
    periods.length.must_equal 2
    periods.must_be_kind_of(Array)
    
    periods[0][:name].must_equal '2012-03'
    periods[1][:name].must_equal '2013-03'
    
    
    periods[0][:records].to_a.length.must_equal 1
    periods[1][:records].to_a.length.must_equal 1
    
    periods[0][:records].to_a.last.must_equal r_2012.last # exact elements
    periods[1][:records].to_a.last.must_equal r_2013.last # exact elements
    
    
    # yeardefault is YOY, latest year and month
    p2_hsh = @recs.compare_periods('YTD', :month=>2)
    
    p2_hsh[:period_type].must_equal 'YTD'
    
    periods = p2_hsh[:periods]
    
    periods.first[:name].must_equal '2012-02'
    periods.last[:name].must_equal '2013-02'
    
    periods.first[:records].to_a.length.must_equal 2
    periods.first[:records].to_a.length.must_equal 2
    
    periods.first[:records].arrivals.must_equal r_2012[0..1].inject(0){|s,a| s+=a.arr_flights}

    periods.last[:records].arrivals.must_equal r_2013[0..1].inject(0){|s,a| s+=a.arr_flights}
  
    
  end
  
  
  
  it "should have named_scope of by_airline" do 
  
    @a1 = FactoryGirl.create(:airline_with_ontime_records, rec_count: 3)
    @a2 = FactoryGirl.create(:airline_with_ontime_records, rec_count: 7)
    

    OntimeRecord.by_airline(@a1).count.must_equal 3
    OntimeRecord.by_airline(@a1).arrivals.must_equal @a1.ontime_records.arrivals
    
    # should accept iata_code  as well
    
    OntimeRecord.by_airline(@a2.iata_code).count.must_equal 7
  
  end

  it "should have named_scope of by_year and by_month" do 
    
    FactoryGirl.create_list(:ontime_record, 8, :month=>8, :year=>2010)
    FactoryGirl.create_list(:ontime_record, 3, :month=>3, :year=>2011)
    
    OntimeRecord.by_year(2010).count.must_equal 8
    OntimeRecord.by_month(3).count.must_equal 3
    
  end




### aggregations
  
  it ":arrivals should sum the number of arrivals" do
    arr =  [100, 500, 600, 700, 200]

    arr.each{|val| ontime_report = FactoryGirl.create(:ontime_record, {arr_flights: val}) }    
    OntimeRecord.arrivals.must_equal arr.inject(0){|s,v| s += v}

  end
  

  it ":delayed_arrivals should sum the number of arrivals" do    
    arr = [10, 20, 30]
    arr.each{|val| ontime_report = FactoryGirl.create(:ontime_record, {arr_del15: val}) }    
    
    OntimeRecord.delayed_arrivals.must_equal 60
  end
  
  it ":delayed_arrivals_rate should average the number of delayed over arrivals" do
    pct = 0.2
    arr =  [100, 500, 600, 700, 200]
    
    arr.each{|val| ontime_report = FactoryGirl.create(:ontime_record, {arr_flights: val, arr_del15: val*pct }) }    
    OntimeRecord.delayed_arrivals_rate.must_equal pct  
  end



  it "should singleton respond to delayed_arrivals suite of aliased methods, and have auto-meta-gen 'rates'" do 

    @x = FactoryGirl.create(:ontime_record, :arrivals=>1020, :delayed_arrivals=>600, 
        :carrier_delayed_arrivals=>100,
        :weather_delayed_arrivals=>120,
        :nas_delayed_arrivals=>130,
        :security_delayed_arrivals=>141,
        :late_aircraft_delayed_arrivals=>109      
      )

     @y = FactoryGirl.create(:ontime_record, :arrivals=>1020, :delayed_arrivals=>6000, 
        :carrier_delayed_arrivals=>1000,
        :weather_delayed_arrivals=>1200,
        :nas_delayed_arrivals=>1300,
        :security_delayed_arrivals=>1410,
        :late_aircraft_delayed_arrivals=>1090      
      )

    OntimeRecord.delayed_arrivals_causes_methods_suite.each do |dmeth|
#      dmeth.to_s.must_be :=~, /_delayed_arrivals$/

      OntimeRecord.must_respond_to dmeth
      OntimeRecord.send(dmeth).must_equal( @x.send(dmeth) + @y.send(dmeth) )

      dmeth_rate = "#{dmeth}_rate".to_sym
      OntimeRecord.must_respond_to dmeth_rate
    end
  end

  it "should do rates with groups" do 

    2.times do 
      airport = FactoryGirl.create(:airport)
      airline = FactoryGirl.create(:airline)
    end

    Airport.all.each do |airport|
      Airline.all.each do |airline|
        3.times do 
          FactoryGirl.create(:ontime_record, :airport=>airport, :airline=>airline, :year=>2009)
          FactoryGirl.create(:ontime_record, :airport=>airport, :airline=>airline, :year=>2010)
          FactoryGirl.create(:ontime_record, :airport=>airport, :airline=>airline, :year=>2011)
          FactoryGirl.create(:ontime_record, :airport=>airport, :airline=>airline, :year=>2012)      
        end
       end 
    end

    aggregation = OntimeRecord.group_and_sum_by(:year)
    aggregation.length.must_equal 4

    agg = aggregation.first
    agg.must_be_kind_of OpenStruct
    yr = agg.year

 
    agg.arrivals.must_equal OntimeRecord.by_year(yr).arrivals
    agg.carrier_delayed_arrivals.must_equal OntimeRecord.by_year(yr).carrier_delayed_arrivals

    agg.weather_delayed_arrivals_rate.must_equal OntimeRecord.by_year(yr).weather_delayed_arrivals_rate






    ###### two facets
    dbl_agg  = OntimeRecord.group_and_sum_by([:year, :month])
    agg = dbl_agg.last

    # ad-hoc feature: date_int

    agg.date_int.must_be_kind_of Integer
    agg.date_epoch_sec.must_equal Date.new(agg.year, agg.month, 1).to_time.to_i

    yr = agg.year
    mth = agg.month

    yr.wont_be_nil
    mth.wont_be_nil

    # the facet by month and year must necessarily be less than the year's entire arrivals
    agg.arrivals.must_be :<=, OntimeRecord.by_year(yr).arrivals
    agg.arrivals.must_equal   OntimeRecord.by_year(yr).by_month(mth).arrivals

    agg.delayed_arrivals_rate.must_equal   OntimeRecord.by_year(yr).by_month(mth).delayed_arrivals_rate


    ###### facet by airline

    airline_agg = OntimeRecord.self_re.group_and_sum_by(:airline_id)
    airline_agg.length.must_equal Airline.count
    agg = airline_agg.first

    # agg must contain (and eager load by default, but not tested -TK) reference to airline relation
    agg.airline.must_be_kind_of Airline
    agg.airline.must_equal Airline.find(agg.airline_id)

    @airline = agg.airline
    agg.arrivals.must_equal @airline.ontime_records.arrivals
    agg.carrier_delayed_arrivals_rate.must_equal @airline.ontime_records.carrier_delayed_arrivals_rate

    ###### triple facet by airport
    airport_aggs = OntimeRecord.group_and_sum_by([:airport_id, :year, :month])
    agg = airport_aggs.first

    mth = agg.month
    yr = agg.year
    airport = agg.airport 

    # specific facet agg should equal equivalent scope of by_year.by_month of an airport's records
    agg.carrier_delayed_arrivals_rate.must_equal airport.ontime_records.by_year(yr).by_month(mth).carrier_delayed_arrivals_rate

    # try a manual agg
    airport_aggs.select{|r| r.airport_id == airport.id}.inject(0){|s,r| s += r.weather_delayed_arrivals}.must_be_within_delta 1.0, airport.ontime_records.weather_delayed_arrivals


    ## test formatters

  end




  it "should accept group_and_sum_by options to use  :limit, and :order" do 

    @airports = 4.times.map do |i| 
      airport = FactoryGirl.create(:airport)
      FactoryGirl.create(:ontime_record, :airport=>airport, :arrivals=>100 * (i+1), :delayed_arrivals=>100/(i+1) )

      airport
    end
    # first airport has most delayed_arrivals
    # last airport has most arrivals



    agg = OntimeRecord.group_and_sum_by(:airport_id, :limit=>2)
    agg.length.must_equal 2 

    ordered_agg = OntimeRecord.group_and_sum_by(:airport_id, :order=>'arrivals DESC')
    ordered_agg.map{|a| a.airport_id}.must_equal @airports.sort_by{|a| a.ontime_records.arrivals }.reverse.map{|a| a.id}

    # test limit and order
    agg = OntimeRecord.group_and_sum_by(:airport_id, :limit=>1, :order=>'delayed_arrivals ASC')
    agg.length.must_equal 1
    agg.first.airport_id.must_equal @airports.last.id



    agg.first.airport.must_be_kind_of Airport



  end


  it "should currently fail to order by rate with :group_and_sum_by" do 
    # group rates are calculated AFTER the SQL query
    FactoryGirl.create_list(:ontime_record, 4)

    Proc.new{ 
      OntimeRecord.group_and_sum_by(:airport_id, :order=>'delayed_arrivals_rate ASC')

    }.must_raise  ActiveRecord::StatementInvalid
 

  end

  it "should have a convenience method :monthly_group_sums to group-sum by month" do 

    @months = (1..5)
    @years = 2010..2012
    @years.each do |yr|
      @months.each do |mth|
        FactoryGirl.create(:ontime_record, :month=>mth, :year=>yr)
      end
    end

    @month = 3
    month_agg = OntimeRecord.monthly_group_sums
    month_agg.length.must_equal @months.count
    month_agg.find{|m| m.month == @month}.arrivals.must_equal OntimeRecord.by_month(@month).arrivals

    @year = @years.last
    year_agg = OntimeRecord.yearly_group_sums
    year_agg.length.must_equal @years.count
    year_agg.find{|y| y.year == @year}.arrivals.must_equal OntimeRecord.by_year(@year).arrivals


    ymth_agg = OntimeRecord.yoy_monthly_group_sums(@month)
    ymth_agg.length.must_equal @years.count 
    ymth_agg.find{|y| y.year == @year}.carrier_delayed_arrivals_rate.must_equal OntimeRecord.by_year(@year).by_month(@month).carrier_delayed_arrivals_rate


#    month_agg.inject(0){|s,r| s + r.arrivals}.must_equal OntimeRecord.by_month(@month).arrivals

  end





  
end
