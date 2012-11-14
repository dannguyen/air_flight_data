require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

describe "AirlineDelayRecord Model" do
  it 'can construct a new instance' do
    @airline_delay_report = AirlineDelayRecord.new
    refute_nil @airline_delay_report
  end
end
