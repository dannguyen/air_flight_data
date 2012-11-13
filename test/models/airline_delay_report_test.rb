require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

describe "AirlineDelayReport Model" do
  it 'can construct a new instance' do
    @airline_delay_report = AirlineDelayReport.new
    refute_nil @airline_delay_report
  end
end
