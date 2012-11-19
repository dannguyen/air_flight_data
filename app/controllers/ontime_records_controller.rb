SkiftAir.controllers :ontime_records do
  # get :index, :map => "/foo/bar" do
  #   session[:foo] = "bar"
  #   render 'index'
  # end

  # get :sample, :map => "/sample/url", :provides => [:any, :js] do
  #   case content_type
  #     when :js then ...
  #     else ...
  # end

  # get :foo, :with => :id do
  #   "Maps to url '/foo/#{params[:id]}'"
  # end

  # get "/example" do
  #   "Hello world!"
  # end

  get :index, :map=>"/ontime" do 

    @airlines = Airline.all
    @airports = Airport.all

    @ontime_records = OntimeRecord.self_re
    @ontime_records_grouped_by_airline = @ontime_records.group_and_sum_by(:airline_id, :round=>2)
    @ontime_records_grouped_by_airport = @ontime_records.group_and_sum_by(:airport_id, :round=>2)

    @earliest_period = @ontime_records.earliest_period
    @latest_period = @ontime_records.latest_period


    # for time series


    render "ontime/index"
  end

  get :delays_by_airline, :map=>"/ontime/airline/:airline" do 
    @airline = Airline.find(params[:airline])
    @ontime_records = @airline.ontime_records.order({:year=>'ASC', :month=>'ASC'})
    @latest_period = @ontime_records.latest_period


    
    @year = @latest_period[:year]
    @month = @latest_period[:month]
    @airline_ytd_records = @ontime_records.by_month(@month).by_year(@year)
          



    @ontime_records_grouped = @ontime_records.group_and_sum_by([:year, :month])
    @stacked_chart_dataseries = OntimeRecord.format_group_sum_for_delay_causes_stacked_chart(@ontime_records_grouped)

    # note ontime_records has to be changed to include outside the scope of ontime_records for @airline TK
    @carrier_caused_timeseries = OntimeRecord.format_group_sum_for_time_series(@ontime_records)


    # tk fix next:
 #   raise "this is an outdated agg:"
    @airports_by_arrivals_sum = @airline.airports_by_arrivals_sum

    render "ontime/delays_by_airline"
  end




  get :delays_by_airport, :map=>"/ontime/airport/:airport" do 
    @airport = Airport.find( params[:airport], :include=>{:ontime_records=>:airline} )

    @ontime_records = @airport.ontime_records.top
    
    @christmas_ontime_records = @ontime_records.christmas
    
    @all_years = @christmas_ontime_records.map{|c| c.year}.uniq.sort
    @airlines = @christmas_ontime_records.map{|r| r.airline}.uniq
    
  
    render "ontime/delays_by_airport"
  end

  get :delays_by_airport_and_airline, :map=>"/ontime/:airport/w/:airline" do
    @airport = Airport.find(params[:airport] ) 
    @airline = Airline.find(params[:airline])
    
    @ontime_records = OntimeRecord.by_airport(@airport).by_airline(@airline)
    
    render "ontime/delays_by_airport_and_airline"
    
  end
  
end
