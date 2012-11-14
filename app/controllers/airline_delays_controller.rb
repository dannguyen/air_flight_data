SkiftAir.controllers :airline_delays do
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

  get :index, :map=>"/airline_delays" do 

    @airlines = Airline.all
    @airports = Airport.all

    render "airline_delays/index"
  end

  get :delays_by_airline, :map=>"/airline_delays/airline/:airline" do 
    @airline = Airline.find(params[:airline])
    @airports_by_arrivals_sum = @airline.airports_by_arrivals_sum

    render "airline_delays/delays_by_airline"
  end



  get :delays_by_airport, :map=>"/airline_delays/airport/:airport" do 
    @airport = Airport.find(params[:airport], :include=>{:airline_delay_records=>:airline})

    @delay_records = @airport.airline_delay_records.top
    
    @christmas_delay_records = @delay_records.christmas
    
    @all_years = @christmas_delay_records.map{|c| c.year}.uniq.sort
    
    @airlines = @christmas_delay_records.map{|r| r.airline}.uniq
    
  
    render "airline_delays/by_airport"
  end

end
