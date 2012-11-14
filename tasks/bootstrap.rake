require 'csv'
require 'logger'
logger.level = Logger::WARN


def geo_degrees_to_decimal(str, opts={})
  #example = 149-59-53.5000W
  #   66-54-50.2000N
  
  puts str
  delimiter = opts[:delimiter] || '-'
  str = str.sub(/[a-z]/i, '')
  dir = $~.to_s.upcase
  
  angle, mins, secs = str.split(delimiter)
  
  return "#{dir=~/W|S/ ? '-' : ''}#{angle}.#{( (mins.to_f/60 + secs.to_f/3600) * 10000 ).to_i}".to_f
end

namespace :bs do
	
	# define irregular column names here
	DATA_DIR = "./tasks/data-hold/bootstrap"
	MODEL_HEADER_MAPS = {
		
		:airports => {
			:headers=>{
				'LocationID'=>'code',
				'FacilityName'=>'name',
				'ARPLatitude'=>'latitude',
			  'ARPLongitude'=>'longitude'				
			},
			:canonical_key=>'code',
			:canonical_list=>true,
			
			:field_conversions=>{
			  'latitude'=>lambda{|f| geo_degrees_to_decimal(f) }, 
			  'longitude'=>lambda{|f| geo_degrees_to_decimal(f)}
			}
			
		},

		:airlines => {
			:headers=>{},
			:canonical_key=>'iata_code',
			:canonical_list=>true
		},

		:ontime_records => {
			:headers=>{
				'carrier'=>'airline_code',
				'airport'=>'airport_code',
				'airport_name'=>'airport_full_name'	
			}
		}#,
		
#		:airport_datums=>{
#		  :headers=>{}
#		}

	}


	task :test => :environment do 
      puts Padrino.env
			puts Airport.count
			Airport.all.each do |a| 
				a.name = a.code
				a.save
			end
	end


	task :entities => :environment do 
		Rake::Task['ar:schema:load'].invoke
		Dir.chdir(DATA_DIR)

		MODEL_HEADER_MAPS.each_pair do |table_name, hsh|
			klass = table_name.to_s.classify.constantize

			header_mappings = hsh[:headers]
			field_conversions = hsh[:field_conversions]

			canon_key = hsh[:canonical_key]
			canon_list =  open("canon_#{table_name}.csv").read.split("\n") if hsh[:canonical_list]

			fname = "#{table_name}.csv"
			puts "Reading from #{fname}"

      count = 0
			 CSV.foreach(fname,  {:headers=>true,
			 							 :header_converters=>lambda{ |hdr_name| 
			 								header_mappings[hdr_name] || hdr_name.underscore
			 							}
			 				 }) do |row|
   	
   	              if field_conversions
   	                field_conversions.each_pair do |key, lam|
   	                    row[key] = lam.call(row[key])
 	                  end
 	                end
   	      
   	
   	        	    record = row.to_hash.slice(*klass.column_names) 

            					if canon_list
            						klass.create(record) if canon_list.index(record[canon_key])
            	   	    else 
            	   	      klass.create(record)	   	      
	   	                end 	
      
                  count +=1
                  puts "Count at #{count}" if count % 1000 == 1
      
                end

      puts "#{klass.count} #{table_name} created"
        
		end
	end
	
	
	task :clean_orphans do 
	  ar = OntimeRecord.where(:airport_id => nil)
	  puts ar.count

    ar.delete_all
  end
end


namespace :prep do
	desc "read from delays.csv and get starter list of airports and airlines"
	task :canon_lists do 


		facets = {'airports'=>{facet:'airport', count:15}, 'airlines'=>{facet:'carrier', count: 6}}		
		
		sets = facets.keys.inject({}){|h, key| h[key] = Hash.new(0); h}

		fname = File.join(DATA_DIR, "ontime_records.csv")

    # get all airlines and all airports
		count_field = 'arr_flights'
		
		CSV.foreach(fname, {:headers=>true, :header_converters=>lambda{|h| h.underscore}}) do |row|
			facets.each_pair do |table, key_hsh|
			  facet_name = key_hsh[:facet]
			  facet = row[facet_name]
				sets[table][facet] += row[count_field].to_i
			end
		end

		sets.each_pair do |table_name, set|
		  keyhsh = facets[table_name]

		  sorted_set = set.sort_by{|k,v| v }.reverse
		  
			cname = File.join(DATA_DIR, "canon_#{table_name}.csv")
			open(cname, 'w') do |f| 
				f.puts sorted_set[0..(keyhsh[:count]-1)].map{|s| s[0]} # retain only the name of the thing, not the arr_flights
			end
		end


	end
end