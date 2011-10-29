require 'spec_helper'

describe SearchesController do

  describe 'new' do
    before do
      get 'new'
    end

    it 'should assing @search' do
      assigns[:search].should be_a(Search)
    end

    it 'should be successful' do
      response.should be_success
    end

    it 'should render :new' do
      response.should render_template(:new)
    end
  end

  describe 'create' do
    before do
      @params = {
        :search => {
          :origin_id => 1,
          :destination_id => 2
        }
      }
      post 'create', @params
    end

    it 'should assign @search' do
      assigns[:search].should be_a(Search)
    end

    it 'should assign @tracks' do
      assigns[:tracks].should_not be_nil
    end

    it 'should render :new' do
      response.should render_template(:new)
    end

    it 'should be successful' do
      response.should be_success
    end
  end

end
