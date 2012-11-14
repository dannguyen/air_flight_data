require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

describe "Airport Model" do
  it 'can construct a new instance' do
    @airport = Airport.new
    refute_nil @airport
  end
  
  it "can build" do 
    airport = FactoryGirl.build(:airport)
    airport.wont_be_nil
  end
  
  
  
end
