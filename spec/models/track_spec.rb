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
    f.save!
    f
  end

  let (:track) { create_track }

  describe 'create_for method' do

    subject { Track.create_for flight }

    [:origin_id, :destination_id, :departure, :arrival, :price].each do |p|
      it "should copy #{p.to_s} from flight" do
        subject[p].should == flight[p]
      end
    end

    it 'should set default values to attributes' do
      subject.transfers_number.should == 0
    end
  end

  describe 'simple track' do
    it 'should have only one flight' do
      t = Track.make!(:flight => flight)
      t.flights.should == [flight]
    end

    it 'should set flight_ids before save' do
      t = Track.make(:flight => flight)
      t.flight_ids.should be_nil
      t.save!
      t.flight_ids.should == flight.id.to_s
    end
  end

  describe 'complex track' do

    before do
      @c1, @c2, @c3 = City.make!(3)
      @f12 = Flight.make({
        :origin => @c1,
        :destination => @c2,
        :departure => DateTime.parse('2011-01-01 12:00:00Z'),
        :arrival => DateTime.parse('2011-01-01 14:00:00Z'),
        :price => 100
      })
      @f23 = Flight.make({
        :origin => @c2,
        :destination => @c3,
        :departure => DateTime.parse('2011-01-01 15:00:00Z'),
        :arrival => DateTime.parse('2011-01-01 18:00:00Z'),
        :price => 250
      })
    end

    it 'should set flight_ids before save' do
      @f12.save!
      @f23.save!
      track = Track.make(:track1 => @f12.track, :track2 => @f23.track)
      track.flight_ids.should be_nil
      track.save!
      track.flight_ids.should == "#{@f12.id},#{@f23.id}"
    end

    it 'should have all the flights from its subtracks' do
      cities = City.make!(6)
      flights = (1..5).map{ |n| Flight.make!(:origin => cities[n-1], :destination => cities[n]) }
      tracks = flights.map { |f| Track.make!(:flight => f) }
      track12 = Track.make!(:track1 => tracks[0], :track2 => tracks[1])
      track34 = Track.make!(:track1 => tracks[2], :track2 => tracks[3])
      track345 = Track.make!(:track1 => track34, :track2 => tracks[4])
      track = Track.make!(:track1 => track12, :track2 => track345)
      track.flights.should == flights
      track.flight_ids.should == flights.map { |f| f.id.to_s }.join(',')
    end

    it 'should add new track to the tail of existing one' do
      @f12.save!
      lambda { @f23.save }.should change { Track.find_by_origin_id_and_destination_id(@c1.id, @c3.id) }.from(nil)

      t13 = Track.find_by_origin_id_and_destination_id(@c1.id, @c3.id)
      t13.departure.should == @f12.departure
      t13.arrival.should == @f23.arrival
      t13.transfers_number.should == 1
      t13.price.should == 350
    end

    it 'should prepend new track to the head of existing one' do
      @f23.save!
      lambda { @f12.save }.should change { Track.find_by_origin_id_and_destination_id(@c1.id, @c3.id) }.from(nil)

      t13 = Track.find_by_origin_id_and_destination_id(@c1.id, @c3.id)
      t13.departure.should == @f12.departure
      t13.arrival.should == @f23.arrival
      t13.transfers_number.should == 1
      t13.price.should == 350
    end

    it 'should not be created if transfer time is too long' do
      @f23.departure = DateTime.parse('2011-11-01 15:00:00Z')
      @f23.arrival = DateTime.parse('2011-11-01 18:00:00Z')
      @f12.save!
      @f23.save!
      Track.find_by_origin_id_and_destination_id(@c1.id, @c3.id).should be_nil
    end

    it 'should not be created if transfer time is too short' do
      @f23.departure = DateTime.parse('2011-01-01 14:01:00Z')
      @f23.arrival = DateTime.parse('2011-01-01 18:00:00Z')
      @f12.save!
      @f23.save!
      Track.find_by_origin_id_and_destination_id(@c1.id, @c3.id).should be_nil
    end

    it 'should not be created if transfers number is too big' do
      @f12.save!
      t = Track.find_by_flight_id(@f12)
      t.update_attribute(:transfers_number, 10)
      @f23.save!
      Track.find_by_origin_id_and_destination_id(@c1.id, @c3.id).should be_nil
    end

    it 'should create triple track when middle chain is created' do
      @c4 = City.make!
      @f34 = Flight.make!({
        :origin => @c3,
        :destination => @c4,
        :departure => DateTime.parse('2011-01-01 18:40:00Z'),
        :arrival => DateTime.parse('2011-01-01 21:00:00Z'),
        :price => 500
      })
      @f12.save!
      lambda { @f23.save }.should change { Track.find_by_origin_id_and_destination_id(@c1.id, @c4.id) }.from(nil)
      t = Track.find_by_origin_id_and_destination_id(@c1.id, @c4.id)
      t.departure.should == @f12.departure
      t.arrival.should == @f34.arrival
      t.transfers_number.should == 2
      t.flights.should == [@f12, @f23, @f34]
      t.price.should == 850
    end

    it 'should destroy dependent tracks when destroying itself' do
      @f12.save!
      @f23.save!
      lambda { Track.destroy(@f12.track) }.should change { Track.all.size }.from(3).to(1)
    end

    it 'should not duplicate tracks with same flights' do
      @c4 = City.make!
      @f34 = Flight.make!({
        :origin => @c3,
        :destination => @c4,
        :departure => DateTime.parse('2011-01-01 18:40:00Z'),
        :arrival => DateTime.parse('2011-01-01 21:00:00Z'),
        :price => 500
      })
      @f12.save!
      @f23.save!
      Track.find_all_by_origin_id_and_destination_id(@c1.id, @c4.id).size.should == 1
    end

    context 'tracks connection time' do

      before do
        @c1, @c2, @c3 = City.make!(3)
        @early_time = DateTime.parse('2011-01-01 00:00:00')
        @time1 = DateTime.parse('2011-01-18 03:00:00')
        @time2 = DateTime.parse('2011-01-18 12:00:00')
        @time3 = DateTime.parse('2011-01-18 21:00:00')
        @late_time = DateTime.parse('2011-02-01 00:00:00')
      end

      def make_flight(origin, destination, departure, arrival, save)
        f = Flight.make(:origin => origin, :destination => destination, :departure => departure, :arrival => arrival)
        f.save! if save
        f
      end

      it 'head arrival should not break allowed transfer interval' do
        f1 = make_flight(@c1, @c2, @early_time, @time1, true)
        f2 = make_flight(@c1, @c2, @early_time, @time2, true)
        f3 = make_flight(@c1, @c2, @early_time, @time3, true)
        departure = DateTime.parse('2011-01-18T21:10:00')
        f = make_flight(@c2, @c3, departure, @late_time, false)
        lambda do
          f.save
        end.should change{ Track.count }.by(2)
        tracks = Track.find_all_by_origin_id_and_destination_id(@c1, @c3)
        tracks.size.should == 1
        tracks.first.flights.should == [f2, f]
      end

      it 'tail departure should not break allowed transfer interval' do
        f1 = make_flight(@c2, @c3, @time1, @late_time, true)
        f2 = make_flight(@c2, @c3, @time2, @late_time, true)
        f3 = make_flight(@c2, @c3, @time3, @late_time, true)
        arrival = DateTime.parse('2011-01-18 02:50:00')
        f = make_flight(@c1, @c2, @early_time, arrival, false)
        lambda do
          f.save
        end.should change{ Track.count }.by(2)
        tracks = Track.find_all_by_origin_id_and_destination_id(@c1, @c3)
        tracks.size.should == 1
        tracks.first.flights.should == [f, f2]
      end
    end

    context 'tracks connection transfers number' do

      before do
        @c1, @c2, @c3 = City.make!(3)
        @tail = Track.make!(
          :origin => @c2,
          :destination => @c3,
          :departure => DateTime.parse('2011-11-11 02:00:00'),
          :arrival => DateTime.parse('2011-11-11 03:00:00'),
          :flight_id => 12,
          :transfers_number => 1
        )
        @head = Track.make(
          :origin => @c1, 
          :destination => @c2, 
          :departure => DateTime.parse('2011-11-11 00:00:00'),
          :flight_id => 13,
          :arrival => DateTime.parse('2011-11-11 01:00:00')
        )
      end

      it 'should be able to reach max transfers number' do
        @head.transfers_number = 1
        lambda { @head.save }.should change{ Track.count }.by(2)
      end

      it 'should not exceed max transfers number' do
        @head.transfers_number = 2
        lambda { @head.save }.should change{ Track.count }.by(1)
      end

    end

  end

end
