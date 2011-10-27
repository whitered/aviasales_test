require 'machinist/active_record'

# Add your blueprints here.
#
# e.g.
#   Post.blueprint do
#     title { "Post #{sn}" }
#     body  { "Lorem ipsum..." }
#   end

City.blueprint do
  name { "City_#{sn}" }
end

Flight.blueprint do
  departure { 2.hours.from_now }
  arrival { 4.hours.from_now }
  price { 1000 }
end

Track.blueprint do
  departure { 2.hours.from_now }
  arrival { 4.hours.from_now }
  price { 1000 }
end
