class Track < ActiveRecord::Base
  belongs_to :origin, :class_name => 'City'
  belongs_to :destination, :class_name => 'City'

  belongs_to :flight
  belongs_to :track1, :class_name => 'Track'
  belongs_to :track2, :class_name => 'Track'

end
