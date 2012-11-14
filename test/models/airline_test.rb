require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

describe "Airline Model" do
  
  before do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
  end
  
  
  
  it 'can construct a new instance' do
    @airline = Airline.new
    refute_nil @airline
  end
  
  it "can build" do 
    airline = FactoryGirl.build(:airline)
    airline.wont_be_nil
  end
end
