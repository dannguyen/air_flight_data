require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

describe "Airline Model" do
  it 'can construct a new instance' do
    @airline = Airline.new
    refute_nil @airline
  end
end
