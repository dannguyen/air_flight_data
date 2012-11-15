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
  
  
  it "should have pct of delayed flights" do 
    assert false
  end


  it "should have pct of carrier-fault flights" do 
    assert false
  end

end
