require 'csv'
namespace :bs do
	
	# define irregular column names here
	DATA_DIR = "./tasks/data-hold/bootstrap"
	MODEL_HEADER_MAPS = {
		
		:airports => {
			:headers=>{
				'LocationID'=>'code',
				'FacilityName'=>'name'
			},
			:canonical_key=>'code'
		},

		:airlines => {
			:headers=>{
			},
			:canonical_key=>'iata_code'
		},

		:airline_delay_records => {
			:headers=>{
				'carrier'=>'airline_code',
				'airport'=>'airport_code',
				'airport_name'=>'airport_full_name'	
	
			}
		}

	}


	task :test => :environment do 

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

			canon_key = hsh[:canonical_key]
			canon_list = !canon_key.nil? ? open("canon_#{table_name}.csv").read.split("\n") : false

			fname = "#{table_name}.csv"
			puts "Reading from #{fname}"

			 CSV.foreach(fname,  {:headers=>true,
			 							 :header_converters=>lambda{ |hdr_name| 
			 								header_mappings[hdr_name] || hdr_name.underscore
			 							}
			 				 }) do |row|
   	
   	        	record = row.to_hash.slice(*klass.column_names) 

					if canon_list
						klass.create(record) if canon_list.index(record[canon_key])
					else
	   	        	klass.create(record)
	   	      end 	
          end

          puts "#{klass.count} #{table_name} created"
        
		end
	end
end


namespace :prep do
	desc "read from delays.csv and get starter list of airports and airlines"
	task :create_canon_lists do 

		require 'set'

		facets = {'airports'=>'airport', 'airlines'=>'carrier'}		
		sets = facets.keys.inject({}){|h, key| h[key] = Set.new; h}

		fname = File.join(DATA_DIR, "airline_delay_records.csv")


		CSV.foreach(fname, {:headers=>true, :header_converters=>lambda{|h| h.underscore}}) do |row|
			facets.each_pair do |key, val|
				sets[key] << row[val]
			end
		end


		sets.each_pair do |table_name, set|
			cname = File.join(DATA_DIR, "canon_#{table_name}.csv")
			open(cname, 'w') do |f| 
				f.puts set.to_a
			end
		end


	end
end