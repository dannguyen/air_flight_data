FactoryGirl.define do

  sequence :airport_names do |i|
    "Airline #{i}"
  end

  sequence :airline_names do |i|
    "Airport #{i}"
  end

  sequence :codes do |i|
    arr = ('A'..'Z').to_a
    "#{arr[i%26]}#{arr[(i+9)%26]}#{arr[(i+20)%26]}"
  end

  sequence :integer do |i|
    i
  end


  factory :airport do 
    code { next(:codes) }
    name {|a| next(:airport_names)}
  end

  factory :airline do 
    iata_code{ next(:codes) }
    icao_code{ next(:codes) }
    name {|a| next(:airline_names)}
  end



end