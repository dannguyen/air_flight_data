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

  get :index, :map=>"/" do 

    render "main/index"
    
  end
  
  get :oneoff, :map=>"/oneoff" do 
    @ontime_records = OntimeRecord.self_re
    
    ## airline December performance
    @airlines_december_records = @ontime_records.by_month(12)
    
    @airlines_december_agg_records =  @airlines_december_records.group_and_sum_by([:airline_id, :year], :round=>3)
    

    
    ## airline recent Year over Year records
    @airlines_yoy_ontime_records = @ontime_records.order({:year=>'ASC', :month=>'ASC'})
        
    @latest_period = @airlines_yoy_ontime_records.latest_period
    @year = @latest_period[:year]
    @month = @latest_period[:month]
    
    @periods_to_compare = @airlines_yoy_ontime_records.compare_periods('YOY', :year=>@year, :month=>@month)[:periods]

    @latest_month_aggs = @ontime_records.by_year(@year).by_month(@month).group_and_sum_by([:airline_id])
    
    




## redundant
    @this_period = @periods_to_compare[1]
    @this_period_name = @this_period[:name]
    @this_period_records = @this_period[:records].group_and_sum_by(:airline_id)
    
    @last_period = @periods_to_compare[0]
    @last_period_name = @last_period[:name]
    @last_period_records = @last_period[:records].group_and_sum_by(:airline_id)
    
    
    
    
    render "main/oneoff"
  end
end