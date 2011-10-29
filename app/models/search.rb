class Search < ActiveRecord::Base
  belongs_to :origin, :class_name => 'City'
  belongs_to :destination, :class_name => 'City'

  validates :origin_id, :presence => true
  validates :destination_id, :presence => true

  def find_tracks
    return nil unless valid?
    tracks = Track.where(:origin_id => origin_id, :destination_id => destination_id)
    tracks = tracks.where('departure >= ?', departure_from) unless departure_from.nil?
    tracks = tracks.where('departure <= ?', departure_to) unless departure_to.nil?
    tracks = tracks.where('arrival >= ?', arrival_from) unless arrival_from.nil?
    tracks = tracks.where('arrival <= ?', arrival_to) unless arrival_to.nil?
    tracks = tracks.where('price <= ?', max_price) unless max_price.nil?
    tracks = tracks.where('transfers_number <= ?', max_transfers) unless max_transfers.nil?
    tracks = tracks.order('price').limit(20)
  end
end
