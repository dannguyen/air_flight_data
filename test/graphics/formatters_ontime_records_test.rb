require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')


describe "OntimeRecord data generators" do 
  before do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
  end

  it "should have :format_group_sum_for_time_series" do 

    @years = 2010..2011
    @months = 1..3


    3.times.map do |i| 
      airline = FactoryGirl.create(:airline)
      @years.each do |y|
        @months.each do |m|
         FactoryGirl.create(:ontime_record, :airline=>airline, :year=>y, :month=>m)
       end
      end
    end

    @ontime_records = OntimeRecord
    hsh = OntimeRecord.format_group_sum_for_time_series(@ontime_records, :airline, :carrier_delayed_arrivals_rate)

    hsh[:data_groups].length.must_equal Airline.count 
    hsh[:data_groups].each{|d| d[:entity].must_be_kind_of Airline}

    dg = hsh[:data_groups].first

    airline = dg[:entity]
    datum = dg[:data].sort_by{|d| d[:x]}.first #earliest day
    yr = @years.first 
    mth = @months.first

    datum[:x].must_equal foo_to_date_int(yr, mth)
    datum[:y].must_equal airline.ontime_records.by_month(mth).by_year(yr).carrier_delayed_arrivals_rate


  end




  it "should have formatter for stacked area chart" do

    @months = (1..5)
    @years = 2010..2012
    @years.each do |yr|
      @months.each do |mth|
        FactoryGirl.create(:ontime_record, :month=>mth, :year=>yr)
      end
    end

    @records = OntimeRecord.self_re
    # accepts array, not relation
    Proc.new{ OntimeRecord.format_group_sum_for_delay_causes_stacked_chart(@records) }.must_raise ArgumentError


    @aggs = @records.group_and_sum_by([:year,:month])
    stacked_hsh = OntimeRecord.format_group_sum_for_delay_causes_stacked_chart(@aggs)


    stacked_hsh.must_be_kind_of Hash

    series = stacked_hsh[:series]
    series.must_be_kind_of Array

    hsh = series.first
    hsh.must_be_kind_of Hash

    hsh[:data].must_be_kind_of Array 
    hsh[:data][0][:x].wont_be_nil 
    hsh[:data][0][:x].must_be_kind_of Integer # timestamp
    hsh[:data][0][:x].must_be :>, 0
    hsh[:name].wont_be_nil 


    # must have layer for each rate method
    series.length.must_equal(OntimeRecord.delayed_arrivals_causes_rate_methods_suite.length)
    series.first[:data].length.must_equal @aggs.length # if aggs is faceted by a single entity


  end


end

# {
#                        name: "Northeast",
 #                       data: [ { x: -1893456000, y: 25868573 }, { x: -1577923200, y: 29662053 }, { x: -1262304000, y: 34427091 }, { x: -946771200, y: 35976777 }, { x: -631152000, y: 39477986 }, { x: -315619200, y: 44677819 }, { x: 0, y: 49040703 }, { x: 315532800, y: 49135283 }, { x: 631152000, y: 50809229 }, { x: 946684800, y: 53594378 }, { x: 1262304000, y: 55317240 } ],
 #                       color: palette.color()
  #              },