# Helper methods defined here can be accessed in any controller or view in the application

SkiftAir.helpers do
  # def simple_helper_method
  #  ...
  # end


  def number_to_percentage_100(num)
   val = (num * 100.8).round(1)
   number_to_percentage(val, :precision=>1)
  end



end
