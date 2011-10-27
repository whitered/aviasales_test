class Flight < ActiveRecord::Base

  belongs_to :origin, :class_name => 'City'
  belongs_to :destination, :class_name => 'City'

  validates_presence_of :origin_id
  validates_presence_of :destination_id
  validates_presence_of :departure
  validates_presence_of :arrival
end
