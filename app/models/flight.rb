class Flight < ActiveRecord::Base

  belongs_to :origin, :class_name => 'City'
  belongs_to :destination, :class_name => 'City'

  has_one :track

  validates_presence_of :origin_id
  validates_presence_of :destination_id
  validates_presence_of :departure
  validates_presence_of :arrival

  after_save :create_track
  before_update :destroy_track
  before_destroy :destroy_track

  private

  def create_track
    Track.create_for self
  end

  def destroy_track
    Track.destroy(track)
  end
end
