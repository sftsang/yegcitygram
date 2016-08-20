require 'faraday'
require 'sinatra'
require 'json'

get '/yeg-permits' do
	# url = URI('http://data.sfgov.org/resource/rqzj-sfat.json')
  url = URI('https://data.edmonton.ca/resource/rwuh-apwg.json')
	url.query = Faraday::Utils.build_query(
    '$order' => 'permit_date DESC',
    '$limit' => 10,
    '$where' => " latitude IS NOT NULL"+
                " AND longitude IS NOT NULL"
  )

  connection = Faraday.new(url: url.to_s)
  response = connection.get
 
  begin
    collection = JSON.parse(response.body)  

    features = collection.map do |record|
      {
        'job_description' => record['job_description'],
        'geometry' => {
          'type' => 'Point',
          'coordinates' => [
            record['longitude'].to_f,
            record['latitude'].to_f
          ]
        }
      }
      # title = "A mobile food facility permit (number #{record['permit']}) has been approved for a #{record['facilitytype']} serving #{record['fooditems']} at #{record['address']}. The applicant is #{record['applicant']}. Find more schedule information here: #{record['schedule']}."
      # {
      #   'id' => record['objectid'],
      #   'type' => 'Feature',
      #   'properties' => record.merge('title' => title),
      #   'geometry' => {
      #     'type' => 'Point',
      #     'coordinates' => [
      #       record['longitude'].to_f,
      #       record['latitude'].to_f
      #     ]
      #   }
      # }
    end


# {
#   ":@computed_region_da6r_6gkw": "9",
#   "address": "1573 - CHAPMAN WAY SW",
#   "building_type": "Single Detached House (110)",
#   "construction_value": "353400",
#   "count": "1",
#   "floor_area": "1860",
#   "issue_date": "2014-09-22T00:00:00.000",
#   "job_category": "House Combination",
#   "job_description": "To construct a Single Detached House with attached Garage, veranda, fireplace and uncovered deck (3.05m x 4.11m).",
#   "latitude": "53.4097636131173",
#   "legal_description": "Plan 1224706 Blk 2 Lot 67",
#   "location": {
#     "coordinates": [
#       -113.575201,
#       53.409764
#     ],
#     "type": "Point"
#   },
#   "longitude": "-113.575200854544",
#   "month_number": "9",
#   "neighbourhood": "CHAPPELLE AREA",
#   "neighbourhood_numberr": "5462",
#   "permit_date": "2014-09-22T00:00:00.000",
#   "permit_number": "160569906-001",
#   "units_added": "1",
#   "work_type": "(01) New",
#   "year": "2014",
#   "zoning": "RSL"
# }

    content_type :json
    JSON.pretty_generate('type' => 'FeatureCollection', 'features' => features)
  rescue Exception => e
    puts e.message
  end

  
end