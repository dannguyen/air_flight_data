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
    code { generate(:codes) }
    name {|a| generate(:airport_names)}
    
    factory :airport_with_ontime_records do
         ignore do
           rec_count 5
         end

      
         after(:create) do |airport, evaluator|
           FactoryGirl.create_list(:ontime_record, evaluator.rec_count, airport: airport)
         end
    end     
         
  end

  factory :airline do 
    iata_code{ generate(:codes) }
    icao_code{ generate(:codes) }
    name {|a| generate(:airline_names)}
    
    factory :airline_with_ontime_records do
         ignore do
           rec_count 5
         end

      
         after(:create) do |airline, evaluator|
           FactoryGirl.create_list(:ontime_record, evaluator.rec_count, airline: airline)
         end
    end
  end

  factory :ontime_record do |u|
    airport
    airline
    arr_flights{  100 + rand(10000) }
    arr_del15{ arr_flights - rand(arr_flights * 0.2)}
    carrier_ct{  arr_del15 * rand}
    year{ 2005 + rand(7)}
    month{ rand(12) + 1}
  end


end