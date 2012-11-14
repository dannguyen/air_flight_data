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

    render "ontime/index"
  end

  get :delays_by_airline, :map=>"/ontime/airline/:airline" do 
    @airline = Airline.find(params[:airline])
    @airports_by_arrivals_sum = @airline.airports_by_arrivals_sum

    render "ontime/delays_by_airline"
  end



  get :delays_by_airport, :map=>"/ontime/airport/:airport" do 
    @airport = Airport.find(params[:airport], :include=>{:ontime_records=>:airline})

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
