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

  get :by_airline, :map=>"/airline_delays/airline/:airline" do 
    @airline = Airline.find(params[:airline])
    @delay_records = @airline.airline_delay_records

    render "airline_delays/by_airline"
  end

  get :by_airport, :map=>"/airline_delays/airport/:airport" do 
    @airport = Airport.find(params[:airport], :include=>:airline_delay_records)
    @delay_records = @airport.airline_delay_records
    render "airline_delays/by_airport"
  end

end
