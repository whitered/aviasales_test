require 'spec_helper'

describe Flight do

  let :flight do
    f = Flight.make
    f.origin, f.destination = City.make!(2)
    f
  end

  [:origin_id, :destination_id, :departure, :arrival].each do |p|
    it "should have #{p}" do
      flight.should be_valid
      flight[p] = nil
      flight.should be_invalid
    end
  end

  it 'should create track after save' do
    lambda do
      flight.save!
    end.should change { Track.find_by_flight_id(flight) }.from(nil)
    Track.find_by_flight_id(flight).flight.should == flight
  end

  it 'should destroy track before change' do
    flight.save!
    track = Track.find_by_flight_id(flight)
    flight.arrival = 1.day.from_now
    lambda { flight.save! }.should change { Track.find_by_id(track.id) }.from(track).to(nil)
  end

  it 'should destroy track before destroy itself' do
    flight.save!
    track = Track.find_by_flight_id(flight)
    flight.arrival = 1.day.from_now
    lambda { Flight.destroy(flight) }.should change { Track.find_by_id(track.id) }.from(track).to(nil)
  end
end
