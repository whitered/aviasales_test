require 'faker'

NUM_CITIES = 20
MAX_FLIGHTS_FROM_CITY = 100
NUM_DAYS = 7

Track.delete_all
Flight.delete_all
City.delete_all

puts 'Creating cities'
NUM_CITIES.times do 
  City.create({ :name => Faker::Address.city })
end

puts 'Creating flights'
City.all.each do |origin|
  rand(MAX_FLIGHTS_FROM_CITY).times do
    destination = City.first(:offset => rand(NUM_CITIES))
    next if destination == origin
    departure = DateTime.parse("2011-11-#{rand(NUM_DAYS) + 1}T#{rand(24)}:#{rand(60)}:00")
    arrival = departure + (rand(420) + 60).minutes
    price = 10 + rand(990)
    f = Flight.create({
      :origin => origin,
      :destination => destination,
      :departure => departure,
      :arrival => arrival,
      :price => price
    })
    puts "#{f.departure.to_formatted_s(:short)} -> #{f.arrival.to_formatted_s(:short)}    $#{f.price}\t#{f.origin_id}:#{f.origin.name} -> #{f.destination_id}:#{f.destination.name}"
  end
end

puts "Done. Cities: #{City.count}, flights: #{Flight.count}, tracks: #{Track.count}"
