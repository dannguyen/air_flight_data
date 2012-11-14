require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

describe "AirportDatum Model" do
  it 'can construct a new instance' do
    @airport_datum = AirportDatum.new
    refute_nil @airport_datum
  end
end
