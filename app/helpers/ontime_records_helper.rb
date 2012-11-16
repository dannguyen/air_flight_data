
SkiftAir.helpers do

   TABLE_ATTRIBUTE_MAPPINGS = {

#      :ontime_records=>{
         :year=>{ title:'Year', format:'int'} ,
         :month=>{ title:'Month', format:'int'} ,
         :arrivals=>{title:'Arrivals', format:'num'} ,
         :delayed_arrivals_rate=>{title:'% Late Arrivals (by 15+ min)', format:'pct'} ,
         :carrier_delayed_arrivals_rate=>{title:'% Carrier fault', format:'pct'} ,
         :weather_delayed_arrivals_rate=>{title:'% Weather caused', format:'pct'} ,
         :nas_delayed_arrivals_rate=>{title:'% NAS fault', format:'pct'},
         :other_causes_delayed_arrivals_rate => {title:'% Other', format:'pct'},
         :airport=>{title:'Airport', format:'airport'},
         :airline=>{title:'Airline', format:'airline'}


#      }
   }


   def get_month_from_int(val)
      val
   end


   def stat_to_content_tag(model, att_name, tag_name='div', opts={})
      value = nil
      if hsh = stat_get_hash_for_formatting(att_name)


         opts[:class] ||= hsh[:format]

         if model.nil?      
            value = hsh[:title]
         else
             value = model.send(att_name)
             value = stat_to_formatted_value(value, hsh[:format])
           
         end 
      end
         
      content_tag tag_name, value, opts
   #      "<#{tag_name} class=\"#{html_class_name}\">#{value}</#{tag_name}>"

   end


   def stat_to_td(model,att_name, opts={})
      stat_to_content_tag(model, att_name, :td, opts)
   end

   def stat_to_th(att_name, opts={})

      stat_to_content_tag(nil, att_name, :th, opts)
   end



   def stat_to_formatted_value(val, fmt=nil)
      case fmt
      when "num"
         number_with_delimiter(val.to_i)
      when "pct"
         number_to_percentage(100.0*val.to_f, :precision=>3)
      when "month"
         get_month_from_int(val)
      when "airport"
         val.name
      when "airline"
         val.name
      else
         val
      end           
   end


   def stat_get_hash_for_formatting(att_name)
      TABLE_ATTRIBUTE_MAPPINGS[att_name] unless att_name.nil?
   end




end
