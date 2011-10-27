class Track < ActiveRecord::Base
  
  MAX_TRANSFER_DURATION = 12.hours
  MIN_TRANSFER_DURATION = 30.minutes
  MAX_TRANSFERS_NUMBER = 3

  belongs_to :origin, :class_name => 'City'
  belongs_to :destination, :class_name => 'City'

  belongs_to :flight
  belongs_to :track1, :class_name => 'Track'
  belongs_to :track2, :class_name => 'Track'

  after_save :construct_complex_tracks

  def self.create_for flight
    track = flight.build_track
    [:origin_id, :destination_id, :departure, :arrival, :price].each do |p|
      track[p] = flight[p]
    end
    track.transfers_number = 0
    track.transfers_minutes = 0
    track.save!
    track
  end

  private

  def construct_complex_tracks
    arrival_from = departure - MAX_TRANSFER_DURATION
    arrival_to = departure - MIN_TRANSFER_DURATION
    tracks = Track.where(
      :arrival => (arrival_from..arrival_to),
      :destination_id => origin_id,
      :transfers_number => (0..MAX_TRANSFERS_NUMBER - 1)
    )
    tracks.each do |t|
      Track.join_tracks(t, self)
    end
  end

  def self.join_tracks a,b
    Track.create do |t|
      t.origin_id = a.origin_id
      t.destination_id = b.destination_id
      t.departure = a.departure
      t.arrival = b.arrival
      t.price = a.price + b.price
      t.transfers_minutes = ((b.departure - a.arrival) / 60).round
      t.transfers_number = a.transfers_number + b.transfers_number + 1
      t.track1 = a
      t.track2 = b
    end
  end

end
