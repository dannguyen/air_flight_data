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
    
    factory :airport_with_delays do
         # posts_count is declared as an ignored attribute and available in
         # attributes on the factory, as well as the callback via the evaluator
         ignore do
           delays_count 5
         end

         # the after(:create) yields two values; the user instance itself and the
         # evaluator, which stores all values from the factory, including ignored
         # attributes; `create_list`'s second argument is the number of records
         # to create and we make sure the user is associated properly to the post
         after(:create) do |airport, evaluator|
           FactoryGirl.create_list(:airline_delay_record, evaluator.delays_count, airport: airport)
         end
    end     
         
  end

  factory :airline do 
    iata_code{ generate(:codes) }
    icao_code{ generate(:codes) }
    name {|a| generate(:airline_names)}
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