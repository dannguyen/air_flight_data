
describe "MyLazyRecordBase" do
  before do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
  end
  
  
  it "should properly self_re" do 
    FactoryGirl.create_list(:airport, 5)
    Airport.self_re.must_equal Airport.all
  end

  it "should properly self_re and still do aggs" do 
    arr = [10, 20, 40, 50]
    records = arr.map{|a| FactoryGirl.create(:ontime_record, :arr_flights=>a, :year=>2010)}

    arr.pop
    records.last.update_attributes({year: 2015})
    
    OntimeRecord.by_year(2010).self_re.sum(&:arr_flights).must_equal arr.inject(0){
      |s,a| s+=a}
      
  end

  
end