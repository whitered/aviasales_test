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
  after_destroy :destroy_complex_tracks

  def flights
    if flight.nil?
      track1.flights + track2.flights
    else
      [flight]
    end
  end

  def self.create_for flight
    track = flight.build_track
    [:origin_id, :destination_id, :departure, :arrival, :price].each do |p|
      track[p] = flight[p]
    end
    track.transfers_number = 0
    track.save!
    track
  end

private

  def construct_complex_tracks
    find_heads
    find_tails
  end

  def allowed_transfers min
    min = 0 if min < 0
    max = MAX_TRANSFERS_NUMBER - min
    if max < min
      nil
    elsif max = min
      min
    else
      (min..min + 1)
    end
  end

  # to keep track balanced, head can have the same amount or one more transfer than tail
  def find_heads
    transfers = allowed_transfers(transfers_number)
    return if transfers.nil?
    arrival_from = departure - MAX_TRANSFER_DURATION
    arrival_to = departure - MIN_TRANSFER_DURATION

    tracks = Track.where(
      :arrival => (arrival_from..arrival_to),
      :destination_id => origin_id,
      :transfers_number => transfers
    )
    tracks.each do |t|
      Track.join_tracks(t, self)
    end
  end

  # tail can have the same amount or one less transfer than head
  def find_tails
    transfers = (transfers_number == 0) ? 0 : allowed_transfers(transfers_number - 1)
    return if transfers.nil?
    arrival_from = arrival + MIN_TRANSFER_DURATION
    arrival_to = arrival + MAX_TRANSFER_DURATION

    tracks = Track.where(
      :arrival => (arrival_from..arrival_to),
      :origin_id => destination_id,
      :transfers_number => transfers
    )
    tracks.each do |t|
      Track.join_tracks(self, t)
    end
  end

  def self.join_tracks a,b
    Track.create! do |t|
      t.origin_id = a.origin_id
      t.destination_id = b.destination_id
      t.departure = a.departure
      t.arrival = b.arrival
      t.price = a.price + b.price
      t.transfers_number = a.transfers_number + b.transfers_number + 1
      t.track1 = a
      t.track2 = b
    end
  end

  def destroy_complex_tracks
    Track.destroy_all :track1_id => self.id
    Track.destroy_all :track2_id => self.id
  end

end
