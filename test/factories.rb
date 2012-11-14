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

 
  factory :airport do 
    code { next(:codes) }
    name {|a| next(:airport_names)}
  end

  factory :airline do 
    iata_code{ next(:codes) }
    icao_code{ next(:codes) }
    name {|a| next(:airline_names)}
  end

  factory :airline_delay_record do |u|
    airport
    airline
    arr_flights{  100 + rand(10000) }
    arr_del15{ arr_flights - rand(arr_flights * 0.2)}
    carrier_ct{  arr_del15 * rand}
    year{ 2005 + rand(7)}
    month{ rand(12) + 1}
  end


end