require 'spec_helper'

describe Track do

  def create_track
    t = Track.make
    t.origin, t.destination = City.make!(2)
    t
  end

  let :flight do
    f = Flight.make
    f.origin, f.destination = City.make!(2)
    f
  end

  let (:track) { create_track }

  describe 'create_for method' do

    subject { Track.create_for flight }

    [:origin, :destination, :departure, :arrival, :price].each do |p|
      it "should copy #{p.to_s} from flight" do
        subject[p].should == flight[p]
      end
    end

    it 'should set default values to attributes' do
      subject.transfers_number.should == 0
      subject.transfers_minutes.should == 0
    end
  end

  it 'should create complex track, adding new track to the tail of existing one' do
    c1, c2, c3 = City.make!(3)
    f12 = Flight.create do |f|
      f.origin = c1
      f.destination = c2
      f.departure = DateTime.parse('2011-01-01T12:00:00Z')
      f.arrival = DateTime.parse('2011-01-01T14:00:00Z')
      f.price = 100
    end
    f23 = Flight.new do |f|
      f.origin = c2
      f.destination = c3
      f.departure = DateTime.parse('2011-01-01T15:00:00Z')
      f.arrival = DateTime.parse('2011-01-01T18:00:00Z')
      f.price = 250
    end

    lambda { f23.save }.should change { Track.find_by_origin_id_and_destination_id(c1.id, c3.id) }.from(nil)

    t13 = Track.find_by_origin_id_and_destination_id(c1.id, c3.id)
    t13.departure.should == f12.departure
    t13.arrival.should == f23.arrival
    t13.transfers_number.should == 1
    t13.transfers_minutes.should == 60
    t13.price.should == 350
  end

end