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
end
