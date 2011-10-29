require 'spec_helper'

describe Search do

  it 'should validate origin_id presence' do
    s = Search.make(:origin_id => nil)
    s.should be_invalid
    s.origin_id = 1
    s.should be_valid
  end

  it 'should validate destination_id presence' do
    s = Search.make(:destination_id => nil)
    s.should be_invalid
    s.destination_id = 2
    s.should be_valid
  end

  describe 'find_tracks' do
    before do
      @t1 = Track.make!(
        :origin_id => 1,
        :destination_id => 2,
        :departure => DateTime.parse('2011-11-11 11:11:11'),
        :arrival => DateTime.parse('2011-11-11 22:22:22')
      )
    end

    it 'should return nil if search is invalid' do
      s = Search.new(:origin_id => 1)
      s.find_tracks.should be_nil
    end

    it 'should not find tracks with wrong departure' do
      @t2 = Track.make!(
        :origin_id => 1,
        :destination_id => 2,
        :departure => DateTime.parse('2011-11-11 12:11:11'),
        :arrival => DateTime.parse('2011-11-11 22:22:22')
      )
      s = Search.new(
        :origin_id => 1,
        :destination_id => 2,
        :departure_from => '11/11/2011 12:00'
      )
      result = s.find_tracks
      result.size.should == 1
      result.should include(@t2)
      result.should_not include(@t1)
    end

    # tons of search parameters specs skipped :)
  end
end
